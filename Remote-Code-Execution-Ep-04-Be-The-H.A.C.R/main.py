from flask import Flask, request

import subprocess

app = Flask(__name__)


@app.route('/')
def vulnerable_function():
    command = request.args.get('cmd', 'cal')
    out = subprocess.check_output(command, shell=True)
    return out
