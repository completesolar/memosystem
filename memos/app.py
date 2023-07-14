import os
from flask import Flask, session
from flask_session import Session
from os.path import join, exists
from shutil import copy

temp_sl = join("memos", "static", "config", "settings_local.py")

if not exists("settings_local.py") and exists(temp_sl):
    copy(temp_sl,"settings_local.py")

try:
    import settings_local
except ImportError:
    pass

for key, value in os.environ.items():
    print(f"{key}: {value}")

# Print all variables defined in the settings_local module
#for var in dir(settings_local):
#    if not var.startswith("__"):
#        print(f"{var}: {getattr(settings_local, var)}")

from memos import create_app
from memos.models.Memo import Memo

app = create_app()

# Flask-Session configuration
app.config['SESSION_TYPE'] = 'filesystem'  # Use 'redis' or 'memcached' for a shared session store in production
Session(app)

from werkzeug.middleware.proxy_fix import ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

@app.context_processor
def inject_pinned():
    return dict(get_pinned=Memo.get_pinned)

if __name__ == '__main__':
    app.run(debug=True)
