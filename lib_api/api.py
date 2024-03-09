import tensorflow as tf
from flask import Flask, request, jsonify
from flask_restful import Api, Resource
from keras.models import load_model
import os
import librosa
import matplotlib.pyplot as plt
import json
from pydub import AudioSegment

app = Flask(__name__)
api = Api(app)

# Load TensorFlow SavedModel (assuming "saved_model.pb" exists)
loaded_model = load_model("up_dataset_model.h5")


class AudioClassifier(Resource):

    def post(self):
        # Check for missing file in request
        if 'file' not in request.files:
            return {'error': 'No file provided'}, 400

        audio_file = request.files['file']

        # Save the uploaded file to a temporary location
        temp_file_path = 'temp_audio.wav'
        audio_file.save(temp_file_path)

        x =('temp_audio.wav')

        output_file = 'aa'
        x = convert_to_wav(x)
        
        x = tf.io.read_file(str(x))
        x = tf.audio.decode_wav(x, desired_channels=1, desired_samples=16000,)
        x = tf.squeeze(x, axis=-1)
        # waveform = x
        x = get_spectrogram(x)
        x = x[tf.newaxis,...]

        predictions = loaded_model.predict(x)
        x_labels = ['isang', 'maliit', 'maya', 'mayang', 'si', 'uhaw']

        os.remove(temp_file_path)
        
        # Get the index of the most probable predicted class
        predicted_class_index = tf.argmax(predictions[0]).numpy()

        # Get the corresponding label from x_labels
        predicted_word = x_labels[predicted_class_index]

        print(predictions)

        json_string = json.dumps(predicted_word)
        return json_string

def get_spectrogram(x):
    # Convert the waveform to a spectrogram via a STFT.
    spectrogram = tf.signal.stft(x, frame_length=255, frame_step=128)
        # Obtain the magnitude of the STFT.
    spectrogram = tf.abs(spectrogram)
        # Add a `channels` dimension, so that the spectrogram can be used
        # as image-like input data with convolution layers (which expect
        # shape (`batch_size`, `height`, `width`, `channels`).
    spectrogram = spectrogram[..., tf.newaxis]
    return spectrogram

def convert_to_wav(x):
    # Load the audio file
    audio = AudioSegment.from_file(x)
    
    # Set parameters for conversion
    sample_rate = 16000
    bit_depth = 16
    channels = 1  # Mono

    audio = audio.set_frame_rate(sample_rate).set_channels(channels)

    # Generate a unique filename (optional)
    output_filename = f"converted_{x.split('/')[-1]}"  # Example

    # Export the audio in WAV format
    audio.export(output_filename, format="wav")

    return output_filename  # Return the generated filename
    

api.add_resource(AudioClassifier, '/classify')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
  