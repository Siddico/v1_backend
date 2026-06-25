
import scipy.io
import numpy as np
import tensorflow as tf
import json
import sys

SEGMENT_LEN = 1250

model = tf.keras.models.load_model("model.keras")

with open("labels.json") as f:
    labels = json.load(f)["classes"]

mat_file = sys.argv[1]

mat = scipy.io.loadmat(mat_file)

signal = mat["PPG_raw_buffer"].flatten()

signal = signal[:SEGMENT_LEN]

if len(signal) < SEGMENT_LEN:
    signal = np.pad(signal, (0, SEGMENT_LEN-len(signal)))

signal = signal.astype(np.float32)

signal = signal.reshape(1, SEGMENT_LEN, 1)

pred = model.predict(signal, verbose=0)

idx = np.argmax(pred)

print("=" * 50)
print("Prediction :", labels[idx])
print("Confidence :", float(pred[0][idx]))
print("Probabilities :", pred[0])
print("=" * 50)
