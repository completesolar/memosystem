import os

os.environ['FLASK_APP'] = "app.py"
os.environ['FLASK_DEBUG'] = 'True'
os.environ['FLASK_ENV'] = 'development'

#os.environ['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
#os.environ['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://user:password@test.local/MEMOS'
os.environ['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://memosystem:memopw@mysql/memos'
#os.environ['SQLALCHEMY_TRACK_MODIFICATIONS'] = 'False'
# set this to 'SQLALCHEMY_ECHO' to 'True' or 'False' to print (or not) the SQL
os.environ['SQLALCHEMY_ECHO'] = 'True'

os.environ['MEMOS_SECRET_KEY'] = '5791628bb0b13ce0c676dfde280ba245'

os.environ['MEMOS_EMAIL_SERVER'] = 'smtp.google.com'
os.environ['MEMOS_EMAIL_PORT'] = '587'
os.environ['MEMOS_EMAIL_USER'] = ''
os.environ['MEMOS_EMAIL_PASS'] = ''

# if you want to turn on registration and your are not using LDAP
os.environ['ENABLE_REGISTER']='false'

os.environ['SESSION_TYPE'] = "filesystem"