from flask import Flask, request, jsonify
from pymongo import MongoClient
import bcrypt
import numpy as np
import pandas as pd
import re
from sklearn.preprocessing import MaxAbsScaler
from sklearn.neighbors import NearestNeighbors
import os
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

password = os.environ.get("MONGODB_PWD")

if not password:
    raise ValueError("MONGODB_PWD environment variable is not set!")

app = Flask(__name__)

mongo_uri = f"mongodb+srv://root:{password}@deepcluster.xcqiz7a.mongodb.net/?retryWrites=true&w=majority"
client = MongoClient(mongo_uri)
db = client['mydatabase']
users_collection = db['users']

anime = pd.read_csv("Anime-Recommendation-master/anime.csv")
anime.loc[(anime["genre"]=="Hentai") & (anime["episodes"]=="Unknown"),"episodes"] = "1"
anime.loc[(anime["type"]=="OVA") & (anime["episodes"]=="Unknown"),"episodes"] = "1"
anime.loc[(anime["type"] == "Movie") & (anime["episodes"] == "Unknown"),"episodes"] = "1"

known_animes = {
    "Naruto Shippuuden": 500, "One Piece": 784, "Detective Conan": 854,
    "Dragon Ball Super": 86, "Crayon Shin chan": 942, "Yu Gi Oh Arc V": 148,
    "Shingeki no Kyojin Season 2": 25, "Boku no Hero Academia 2nd Season": 25,
    "Little Witch Academia TV": 25
}

for k, v in known_animes.items():    
    anime.loc[anime["name"] == k, "episodes"] = v

anime["episodes"] = anime["episodes"].map(lambda x: np.nan if x == "Unknown" else x)
anime["episodes"].fillna(anime["episodes"].median(), inplace=True)
anime["rating"] = anime["rating"].astype(float)
anime["rating"].fillna(anime["rating"].median(), inplace=True)
anime["members"] = anime["members"].astype(float)

anime_features = pd.concat([
    anime["genre"].str.get_dummies(sep=","), pd.get_dummies(anime[["type"]]),
    anime[["rating"]], anime[["members"]], anime["episodes"]
], axis=1)

anime["name"] = anime["name"].map(lambda name: re.sub('[^A-Za-z0-9]+', " ", name))

max_abs_scaler = MaxAbsScaler()
anime_features = max_abs_scaler.fit_transform(anime_features)

nbrs = NearestNeighbors(n_neighbors=6, algorithm='ball_tree').fit(anime_features)
distances, indices = nbrs.kneighbors(anime_features)

def get_index_from_name(name):
    return anime[anime["name"] == name].index.tolist()[0]

@app.route('/register', methods=['POST'])
def register_user():
    data = request.get_json()
    username = data['username']
    password = data['password']
    confirm_password = data['confirmPassword']
    favorite_anime = data['favoriteAnime']

    existing_user = users_collection.find_one({'username': username})
    if existing_user:
        return jsonify({'message': 'Username already exists'}), 400

    if password != confirm_password:
        return jsonify({'message': 'Passwords do not match'}), 400

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    user_data = {
        'username': username,
        'password': hashed_password,
        'favoriteAnime': favorite_anime
    }
    users_collection.insert_one(user_data)

    return jsonify({'message': 'Registration successful'}), 200

@app.route('/login', methods=['POST'])
def login_user():
    data = request.get_json()
    username = data['username']
    password = data['password']

    user = users_collection.find_one({'username': username})
    if not user:
        return jsonify({'message': 'User not found'}), 404

    if bcrypt.checkpw(password.encode('utf-8'), user['password']):
        return jsonify({'message': 'Login successful'}), 200
    else:
        return jsonify({'message': 'Invalid credentials'}), 401

@app.route('/get_users_with_similar_favorite_anime', methods=['GET'])
def get_users_with_similar_favorite_anime():
    favorite = request.args.get('favoriteAnime')
    pipeline = [
        {
            "$search": {
                "index": "anime", 
                "autocomplete": {
                    "query": favorite,
                    "path": "favoriteAnime",
                    "tokenOrder": "sequential",
                }
            }
        },
        {
            "$project": {
                "username": 1,
                "favoriteAnime": 1,
                "_id": 0
            }
        }
    ]
    users = users_collection.aggregate(pipeline)
    result = list(users)
    return jsonify(result), 200

@app.route('/get_anime_recommendations', methods=['GET'])
def get_anime_recommendations():
    anime_name = request.args.get('anime_name')
    if anime_name:
        anime_id = get_index_from_name(anime_name)
        similar_anime_ids = indices[anime_id][1:]
        similar_anime_names = [anime.iloc[id]["name"] for id in similar_anime_ids]
        return jsonify(similar_anime_names)
    
    return jsonify({"error": "Invalid parameters."})

if __name__ == '__main__':
    app.run(debug=True)
