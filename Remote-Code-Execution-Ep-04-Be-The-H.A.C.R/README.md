## About this Project

This is a vulnerable web application whose purpose is to demonstrate Remote Code Execution ( RCE ).

## Setup
1. Download the zip of this repo or git clone the repo. Extract the repo ( if you've downloaded the zip ).
2. Make sure you're in the project folder i.e. your current working directory should be this folder.
3. Make sure you've virtualenv setup ( Please google that and setup it if not ), it's not necessary but recommended.
4. (optional step) Create a virtual environment with the name `venv` using `virtualenv venv`.
5. Install the required packages using `pip install -r requirements.txt`
6. To run the flask application execute the following : 
    `export FLASK_APP=main.py` 
    `flask run`
7. You're all done. 
You should see a screen with the following output : 
```bash
 * Serving Flask app "main.py"
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```
![image](https://user-images.githubusercontent.com/17861054/82240641-62ae8e00-9958-11ea-8dba-977b1c16c9b9.png)



To view the vulnerable web application open : http://127.0.0.1:5000/ in your browser

To execute a command : http://127.0.0.1:5000/?cmd=<insert_your_command_here>

e.g.

    http://127.0.0.1:5000/?cmd=ls  ( for Linux and Mac )
    http://127.0.0.1:5000/?cmd=dir ( for windows )
