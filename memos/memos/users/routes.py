""" User Routes """
import os
from flask import render_template, url_for, flash, redirect, request, Blueprint, current_app, abort, session, Flask
from flask_login import login_user, current_user, logout_user, login_required
from memos import db
from memos.flask_sqlalchemy_txns import transaction

from memos.users.forms import (RegistrationForm, LoginForm, UpdateAccountForm,
                               RequestResetForm, ResetPasswordForm)
from memos.users.utils import save_picture, send_reset_email
from memos.models.User import User
from memos.extensions import ldap

import os
import identity.web

# Google Login imports
import google_auth_oauthlib.flow
import requests
# debug
from pprint import pprint

# Uncomment for local testing http
os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
AUTHORITY = os.getenv("AUTHORITY")
REDIRECT_PATH = os.getenv("REDIRECT_PATH")
ENDPOINT =  os.getenv("ENDPOINT")
SCOPE = os.getenv("SCOPE")
SESSION_TYPE = os.getenv("SESSION_TYPE")
ENV_URL = os.getenv("ENV_URL")

auth = identity.web.Auth(
    session=session,
    authority=AUTHORITY,
    client_id=CLIENT_ID,
    client_credential=CLIENT_SECRET,
)

users = Blueprint('users', __name__)
#Google Credentials
users.secret_key = os.getenv("G_SECRET")
CLIENT_ID = os.getenv("G_CLIENT_ID")
CLIENT_SECRET = os.getenv("G_CLIENT_SECRET")

REDIRECT_URI = os.getenv("G_REDIRECT_URI")
# REDIRECT_URI = 'http://localhost:80/getAToken'
SCOPES = ['openid','https://www.googleapis.com/auth/drive.metadata.readonly', 'https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/userinfo.profile']
# END Google Credentials

# Google login flow.
# Connect and validate credentials.
# Get user token on success.
@users.route("/sign_in")
def sign_in():
    flow = google_auth_oauthlib.flow.Flow.from_client_config(
        {
            "web": {
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "redirect_uris": [REDIRECT_URI]
            }
        }, SCOPES
    )

    flow.redirect_uri = REDIRECT_URI
    authorization_url, _ = flow.authorization_url(
        access_type='offline',
        include_granted_scopes='true'
    )
    return redirect(authorization_url)

@users.route("/login", methods=['GET'])
def login():
    if auth.get_user():
        print(auth.get_user())
        return redirect(url_for('main.home'))
    else:
        session.pop('session', None)
        return render_template("login.html", **auth.log_in(
            scopes=SCOPE,
            redirect_uri=ENV_URL+"/getAToken",
        ))


@users.route(REDIRECT_PATH)
def get_a_token():
    flow = google_auth_oauthlib.flow.Flow.from_client_config(
        {
            "web": {
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "redirect_uris": [REDIRECT_URI]
            }
        }, SCOPES
    )

    flow.redirect_uri = REDIRECT_URI
    flow.fetch_token(authorization_response=request.url)

    # Getting user's info
    token = flow.credentials.token
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get('https://www.googleapis.com/oauth2/v1/userinfo', headers=headers).json()
    pprint(response)

    if not response:
        return render_template("auth_error.html", result="Invalid Authentication, Validate information")
    else:
        session['user'] = response['email']
        # email from the token
        user_email = response['email']

        # Look up the user based on their email address
        user = User.query.filter_by(email=user_email).first()

        if user is None:
            # Create the user and add to the database
            user_name = user_email.split('@')[0].lower()  # username derived from the email

            user = User(
                username=user_name,
                email=user_email,
                image_file='default.jpg',
                password='0123456',
                admin=0,
                readAll=0,
                pagesize=10
            )

            db.session.add(user)
            db.session.commit()

        # Regardless of whether the user was just created or already existed, log them in
        login_user(user)

    return redirect(url_for("main.home"))  # Changed from "index" to "main.home"


@users.route("/logout")
def logout():
    """
    This function logs the user out
    """
    with transaction():
        logout_user()
        return redirect(auth.log_out(url_for("main.home", _external=True)))


@users.route("/account", methods=['GET', 'POST'])
@users.route("/account/<string:username>", methods=['GET', 'POST'])
@login_required
def account(username=None):
    """_summary_

    Args:
        username (_type_, optional): _description_. Defaults to None.

    Returns:
        _type_: _description_
    """
    with transaction():
        form = UpdateAccountForm()

        if username is None:
            user = current_user
        else:
            user = User.find(username=username)

        if user is None:
            abort(404)

        #        current_app.logger.info(f"User = {current_user.username} Delegate List= {user.delegates}")
        disable_submit_button = None
        if form.validate_on_submit():

            #            current_app.logger.info(f"User = {user} current_user={current_user} formusername={form.username.data}")
            if user != current_user and not current_user.admin:
                abort(403)

            if form.picture.data:
                picture_file = save_picture(form.picture.data)
                user.image_file = picture_file

            if not ldap and current_user.admin:
                user.admin = form.admin.data
                user.readAll = form.readAll.data

            if not ldap:
                current_app.logger.info(f"Email = {type(form.email.data)}")
                user.email = form.email.data

            user.delegates = form.delegates.data
            user.pagesize = form.pagesize.data
            user.subscriptions = form.subscriptions.data
            db.session.add(user)
            flash('Your account has been updated!', 'success')

        # After update, reload the page. GET starts here

        form.username.render_kw['disabled'] = True
        form.email.render_kw['disabled'] = False
        form.delegates.render_kw['disabled'] = False
        form.admin.render_kw['disabled'] = False
        form.readAll.render_kw['disabled'] = False
        form.subscriptions.render_kw['disabled'] = False
        form.pagesize.render_kw['disabled'] = False

        disable_submit_button = False

        current_app.logger.info(
            f"username={user.username} email={user.email} readAll={user.readAll} admin={user.admin}")

        form.username.data = user.username
        form.email.data = user.email
        form.admin.data = user.admin
        form.readAll.data = user.readAll
        form.delegates.data = user.delegates['usernames']
        form.subscriptions.data = user.subscriptions
        form.pagesize.data = user.pagesize

        if not (user == current_user or current_user.admin):
            form.username.render_kw['disabled'] = True
            form.email.render_kw['disabled'] = True
            form.delegates.render_kw['disabled'] = True
            form.admin.render_kw['disabled'] = True
            form.readAll.render_kw['disabled'] = True
            form.subscriptions.render_kw['disabled'] = True
            form.pagesize.render_kw['disabled'] = True
            disable_submit_button = True

        if ldap:  # pragma nocover - all of these characteristics come from the LDAP groups
            form.username.render_kw['disabled'] = True
            form.email.render_kw['disabled'] = True
            form.admin.render_kw['disabled'] = True
            form.readAll.render_kw['disabled'] = True

        image_file = url_for('static', filename='profile_pics/' + user.image_file)

        return render_template('account.html', username=user.username, title='Account',
                               image_file=image_file, form=form, user=user, disable_submit_button=disable_submit_button)


@users.route("/reset_password", methods=['GET', 'POST'])
def reset_request():
    if 'ENABLE_REGISTER' not in current_app.config or not current_app.config['ENABLE_REGISTER']:
        abort(404)  # pragma nocover

    with transaction():
        if current_user.is_authenticated:
            return redirect(url_for('main.home'))
        form = RequestResetForm()
        if form.validate_on_submit():
            user = User.query.filter_by(email=form.email.data)
            if user.count() == 1 and len(user[0].email) > 2:
                send_reset_email(user[0])
                flash('An email has been sent with instructions to reset your password.', 'info')
            elif user.count() > 1:
                flash('That email is not unique to one account. Cannot send reset email. Contact system administrator.',
                      'warning')
                return redirect(url_for('users.reset_request'))
            else:
                flash('There is no account with that email. You must register first.', 'warning')
                return redirect(url_for('users.reset_request'))
            return redirect(url_for('users.login'))
        return render_template('reset_request.html', title='Reset Password', form=form)


@users.route("/reset_password/<token>", methods=['GET', 'POST'])
def reset_token(token):
    if 'ENABLE_REGISTER' not in current_app.config or not current_app.config['ENABLE_REGISTER']:
        abort(404)  # pragma nocover

    with transaction():
        if current_user.is_authenticated:
            return redirect(url_for('main.home'))
        user = User.verify_reset_token(token)
        if user is None:
            flash('That is an invalid or expired token', 'warning')
            return redirect(url_for('users.reset_request'))
        form = ResetPasswordForm()
        if form.validate_on_submit():
            hashed_password = User.create_hash_pw(form.password.data)
            user.password = hashed_password
            flash('Your password has been updated! You are now able to log in', 'success')
            return redirect(url_for('users.login'))
        return render_template('reset_token.html', title='Reset Password', form=form)
