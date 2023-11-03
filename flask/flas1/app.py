from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def hello_world():
    one = 4
    two = 1
    result = str(sum([one, two]))
    return render_template('home.html', result=result, one=one, two=two)


@app.route('/py')
def pyme():
    return 'Hello World'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5020, debug=True)
