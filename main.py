from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from io import BytesIO
import base64
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor, AdaBoostRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR
import lightgbm as lgb
import xgboost as xgb
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from flask_cors import CORS
import spacy
import random
from sklearn import datasets as sklearn_datasets
import seaborn as sns

app = Flask(__name__)
CORS(app)

# Load NLP model for chatbot
nlp = spacy.load("en_core_web_sm")

# Dataset Configuration (Using Libraries Instead of CSV)
datasets = {
    "Iris Dataset": "iris",
    "California Housing": "california_housing",
    "Diabetes": "diabetes",
    "Wine Quality": "wine",
    "Titanic": "titanic"
}

# Algorithm Configurations
algorithms = {
    "Random Forest Regressor": RandomForestRegressor(),
    "Decision Tree": DecisionTreeRegressor(),
    "SVM": SVR(),
    "LightGBM": lgb.LGBMRegressor(),
    "Gradient Boosting": GradientBoostingRegressor(),
    "AdaBoost": AdaBoostRegressor(),
    "XGBoost": xgb.XGBRegressor(),
    "Linear Regression": LinearRegression(),
    "Ridge Regression": Ridge(),
    "Lasso Regression": Lasso()
}

dataset_info = {
    "Iris Dataset": "Classification of iris flowers into three species.",
    "California Housing": "Predicts median house values based on census data.",
    "Diabetes": "Predicts diabetes progression based on medical data.",
    "Wine Quality": "Predicts wine quality based on physicochemical tests.",
    "Titanic": "Passenger survival data from the Titanic disaster."
}

@app.route('/get_dataset_info', methods=['GET'])
def get_dataset_info():
    return jsonify(dataset_info)


# Load dataset from a library
def load_dataset(dataset_name):
    if dataset_name == "iris":
        data = sklearn_datasets.load_iris(as_frame=True)
        df = data.frame
    elif dataset_name == "california_housing":
        data = sklearn_datasets.fetch_california_housing(as_frame=True)
        df = pd.DataFrame(data.data, columns=data.feature_names)
        df['target'] = data.target
    elif dataset_name == "diabetes":
        data = sklearn_datasets.load_diabetes(as_frame=True)
        df = data.frame
    elif dataset_name == "wine":
        data = sklearn_datasets.load_wine(as_frame=True)
        df = data.frame
    elif dataset_name == "titanic":
        df = sns.load_dataset("titanic").dropna()  # Load Titanic dataset from Seaborn
    else:
        return None
    return df

# API to get dataset list
@app.route('/get_datasets', methods=['GET'])
def get_datasets():
    return jsonify({"datasets": list(datasets.keys())})

# API to get algorithm list
@app.route('/get_algorithms', methods=['GET'])
def get_algorithms():
    return jsonify({"algorithms": list(algorithms.keys())})

# API to get dataset sample
@app.route('/dataset_sample', methods=['GET'])
def dataset_sample():
    dataset_name = request.args.get('dataset', '')
    df = load_dataset(datasets.get(dataset_name))
    if df is not None:
        return jsonify({"sample": df.head().to_dict(orient='records')})
    return jsonify({"error": "Dataset not found"}), 404

# API to compare algorithms
@app.route('/compare', methods=['POST'])
def compare_algorithms():
    try:
        data = request.json
        dataset_name = datasets.get(data.get('dataset'))
        algo1_name = data.get('algorithm1')
        algo2_name = data.get('algorithm2')

        if dataset_name not in datasets.values() or algo1_name not in algorithms or algo2_name not in algorithms:
            return jsonify({"error": "Invalid dataset or algorithm"}), 400

        # Load dataset
        df = load_dataset(dataset_name)
        if df is None:
            return jsonify({"error": "Dataset not found"}), 404

        # Assuming last column as target variable
        X = df.iloc[:, :-1]
        y = df.iloc[:, -1]

        # Splitting dataset
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        # Train models
        model1 = algorithms[algo1_name]
        model2 = algorithms[algo2_name]

        model1.fit(X_train, y_train)
        model2.fit(X_train, y_train)

        # Predictions and performance metrics
        pred1 = model1.predict(X_test)
        pred2 = model2.predict(X_test)

        metrics = lambda y_true, y_pred: (
            mean_absolute_error(y_true, y_pred),
            mean_squared_error(y_true, y_pred),
            r2_score(y_true, y_pred)
        )

        mae1, mse1, r2_1 = metrics(y_test, pred1)
        mae2, mse2, r2_2 = metrics(y_test, pred2)

        # Determine the better algorithm
        best_algo = algo1_name if mse1 < mse2 else algo2_name

        # Generate comparison graph
        plt.figure(figsize=(6, 4))
        sns.barplot(x=[algo1_name, algo2_name], y=[mae1, mae2], palette="coolwarm")
        plt.title("Algorithm Performance Comparison")
        plt.ylabel("Mean Absolute Error")
        plt.xlabel("Algorithms")

        buf = BytesIO()
        plt.savefig(buf, format="png")
        buf.seek(0)
        graph_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        plt.close()

        result = {
            "best_algorithm": best_algo,
            "metrics": {
                "MSE1": mse1,
                "MSE2": mse2,
                "MAE1": mae1,
                "MAE2": mae2,
                "R2_1": r2_1,
                "R2_2": r2_2
            },
            "comparison_graph": graph_base64
        }

        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/tutorials', methods=['GET'])
def get_tutorials():
    tutorials = [
        {
            "title": "Python Basics",
            "description": "Learn Python from scratch.",
            "content": "Python is a versatile language used in web development, data science, and AI..."
        },
        {
            "title": "Machine Learning Intro",
            "description": "Discover Machine Learning concepts.",
            "content": "Machine Learning is a field of AI that enables computers to learn from data..."
        }
    ]
    return jsonify({"tutorials": tutorials})

# Chatbot - Enhanced with NLP
ml_interview_questions = {
    "decision tree": [
        "What is a Decision Tree?",
        "How does pruning help in Decision Trees?",
        "What are the advantages of Decision Trees?"
    ],
    "random forest": [
        "How does Random Forest work?",
        "What is Out-of-Bag (OOB) error in Random Forest?",
        "How does feature importance work in Random Forest?"
    ],
    "svm": [
        "Explain Support Vector Machines (SVM).",
        "What is the kernel trick in SVM?",
        "What are the pros and cons of SVM?"
    ],
    "neural networks": [
        "Explain backpropagation in neural networks.",
        "What are activation functions in deep learning?",
        "What is the vanishing gradient problem?"
    ],
    "cnn": [
        "What is a Convolutional Neural Network (CNN)?",
        "How do CNNs extract features from images?",
        "Explain the role of pooling layers in CNNs."
    ],
    "fallback": ["I couldn't find an interview question on that topic. Can you be more specific?"]
}

# Detect user intent
def detect_intent(user_message):
    doc = nlp(user_message.lower())

    for topic in ml_interview_questions.keys():
        if topic in user_message:
            return topic

    return "fallback"

@app.route('/chatbot', methods=['POST'])
def chatbot():
    user_message = request.json.get('message', '')

    # Detect topic
    topic = detect_intent(user_message)

    # Select a random interview question from the detected topic
    response = random.choice(ml_interview_questions[topic])

    return jsonify({"response": response})

if __name__ == '__main__':
    app.run(debug=True)
