import tensorflow as tf
from flask import Flask, request, jsonify
from flask_restful import Api, Resource
from keras.models import load_model
import os
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
        temp_file_path = ''
        audio_file.save(temp_file_path)

        # Convert audio to WAV format
        output_file = ''
        convert_to_wav(temp_file_path, output_file)

        # Load the WAV file
        audio = AudioSegment.from_file(output_file)

        # Convert audio to TensorFlow tensor
        output_file = tf.constant(audio.get_array_of_samples())

        # Preprocess audio for prediction
        output_file = get_spectrogram(output_file)
        output_file = output_file[tf.newaxis, ...]

        # Predict using the loaded model
        predictions = loaded_model.predict(output_file)
        x_labels = ['isang', 'maliit', 'maya', 'mayang', 'si', 'uhaw']

        # Get the index of the most probable predicted class
        predicted_class_index = tf.argmax(predictions[0]).numpy()

        # Get the corresponding label from x_labels
        predicted_word = x_labels[predicted_class_index]

        # Remove the temporary audio file
        os.remove(temp_file_path)
        os.remove(output_file)

        return jsonify({'predicted_word': predicted_word})

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


def convert_to_wav(input_file, output_file):
    # Load the audio file
    audio = AudioSegment.from_file(input_file)
    
    # Set parameters for conversion
    sample_rate = 16000
    bit_depth = 16
    channels = 1  # Mono
    
    # Set the sample width in bytes
    sample_width = bit_depth // 8
    
    # Set the target sample rate and number of channels
    audio = audio.set_frame_rate(sample_rate).set_channels(channels)
    
    # Set the target sample width
    audio = audio.set_sample_width(sample_width)
    
    # Export the audio in WAV format
    audio.export(output_file, format="wav")

# Add the resource to the API
api.add_resource(AudioClassifier, '/classify')

# Run the Flask application
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
