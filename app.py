from flask import Flask, jsonify, abort, request, make_response, url_for, render_template, redirect, Response, send_from_directory
from urllib.parse import quote
import os
import time
import datetime
import exifread
import json
import pymysql
import requests

pymysql.install_as_MySQLdb()
import MySQLdb

app = Flask(__name__, static_url_path="")

UPLOAD_FOLDER = os.path.join(app.root_path, 'media')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

# Environment variables for DB
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")

def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        db=DB_NAME,
        port=3306
    )

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.errorhandler(400)
def bad_request(error):
    return make_response(jsonify({'error': 'Bad request'}), 400)

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

def getExifData(path_name):
    with open(path_name, 'rb') as f:
        tags = exifread.process_file(f)
    return {tag: str(tags[tag]) for tag in tags if tag not in ('JPEGThumbnail', 'TIFFThumbnail', 'Filename', 'EXIF MakerNote')}

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
        user = cursor.fetchone()
        conn.close()

        if user and user[2] == password:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM photo;")
            results = cursor.fetchall()
            conn.close()

            items = [{"PhotoID": item[0], "CreationTime": item[1], "Title": item[2], "Description": item[3], "Tags": item[4], "URL": item[5]} for item in results]
            return render_template('home.html', photos=items)
        else:
            return render_template('index.html', error="Invalid username or password")
    else:
        return render_template('index.html')

@app.route('/create-user', methods=['GET', 'POST'])
def create_user():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
        user_exists = cursor.fetchone()

        if user_exists:
            conn.close()
            return render_template('create-user.html', error="Username already exists.")

        cursor.execute("INSERT INTO user (username, password) VALUES (%s, %s)", (username, password))
        conn.commit()
        conn.close()

        return render_template('index.html', message="User created successfully. Please log in.")

    return render_template('create-user.html')

@app.route('/home', methods=['GET'])
def home():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM photo;")
    results = cursor.fetchall()
    conn.close()

    items = [{"PhotoID": item[0], "CreationTime": item[1], "Title": item[2], "Description": item[3], "Tags": item[4], "URL": item[5]} for item in results]
    return render_template('home.html', photos=items)

@app.route('/add', methods=['GET', 'POST'])
def add_photo():
    if request.method == 'POST':
        file = request.files['imagefile']
        title = request.form['title']
        tags = request.form['tags']
        description = request.form['description']

        if file and allowed_file(file.filename):
            filename = file.filename
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(file_path)

            ExifData = getExifData(file_path)
            ts = time.time()
            timestamp = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
            file_url = f"/uploads/{filename}"

            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO photo (CreationTime, Title, Description, Tags, URL, ExifData) VALUES (%s, %s, %s, %s, %s, %s)",
                (timestamp, title, description, tags, file_url, json.dumps(ExifData))
            )
            conn.commit()
            conn.close()

        return redirect('/home')
    else:
        return render_template('form.html')

@app.route('/<int:photoID>', methods=['GET'])
def view_photo(photoID):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM photo WHERE PhotoID = %s", (photoID,))
    item = cursor.fetchone()
    conn.close()

    if item:
        tags = item[4].split(',')
        exifdata = json.loads(item[6])
        return render_template('photodetail.html', photo=item, tags=tags, exifdata=exifdata)
    else:
        abort(404)

@app.route('/media/<path:filename>')
def serve_media(filename):
    return send_from_directory('media', filename)

@app.route('/search', methods=['GET'])
def search_page():
    query = request.args.get('query', None)
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM photo WHERE Title LIKE %s OR Description LIKE %s OR Tags LIKE %s", (f'%{query}%', f'%{query}%', f'%{query}%'))
    columns = [column[0] for column in cursor.description]
    items = [dict(zip(columns, row)) for row in cursor.fetchall()]
    conn.close()

    return render_template('search.html', photos=items, searchquery=query)

@app.route('/download/<filename>')
def download_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename, as_attachment=True)

@app.route("/healthz")
def health_check():
    return "OK", 200

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=80)
