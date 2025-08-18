from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import sys
import os
from dotenv import load_dotenv
import asyncio
import json
import threading
import base64
import io
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from gemvoice import AudioLoop

app = Flask(__name__)
CORS(app, origins="*")
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# Global variables to manage state
current_audio_loop = None
audio_thread = None
connected_clients = {}

def run_audio_loop():
    global current_audio_loop
    audio_loop = AudioLoop()
    current_audio_loop = audio_loop
    asyncio.run(audio_loop.run())

@app.route('/start_voice', methods=['POST'])
def start_voice():
    global current_audio_loop, audio_thread
    try:
        # Return WebSocket URL for the client to connect
        websocket_url = f"ws://localhost:5000/socket.io/"
        
        logger.info(f"Starting voice session, WebSocket URL: {websocket_url}")
        
        response = {
            'status': 'success',
            'websocket': {
                'url': websocket_url,
                'protocol': 'socketio'
            },
            'message': 'Voice session initialized. Connect to WebSocket for real-time communication.'
        }
        
        return jsonify(response)
    except Exception as e:
        logger.error(f"Error starting voice session: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/terminate_voice', methods=['POST'])
def terminate_voice():
    global current_audio_loop
    try:
        if current_audio_loop:
            asyncio.run(current_audio_loop.stop())
            current_audio_loop = None
            logger.info("Voice session terminated")
            return jsonify({'status': 'success', 'message': 'Voice session terminated'})
        return jsonify({'status': 'success', 'message': 'No active voice session'})
    except Exception as e:
        logger.error(f"Error terminating voice session: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)})

@socketio.on('connect')
def handle_connect():
    logger.info(f"Client connected: {request.sid}")
    connected_clients[request.sid] = {
        'connected_at': threading.current_thread().name,
        'audio_loop': None
    }
    
    emit('connection_response', {
        'status': 'connected',
        'message': 'Successfully connected to voice service',
        'client_id': request.sid
    })

@socketio.on('disconnect')
def handle_disconnect():
    logger.info(f"Client disconnected: {request.sid}")
    
    # Clean up any running audio loop for this client
    if request.sid in connected_clients:
        client_info = connected_clients[request.sid]
        if client_info.get('audio_loop'):
            try:
                asyncio.run(client_info['audio_loop'].stop())
            except:
                pass
        del connected_clients[request.sid]

@socketio.on('audio')
def handle_audio(data):
    """Handle incoming audio data from client"""
    try:
        logger.info(f"Received audio data from client {request.sid}")
        
        # Start audio loop if not already running
        global current_audio_loop, audio_thread
        if current_audio_loop is None:
            audio_thread = threading.Thread(target=run_audio_loop)
            audio_thread.daemon = True
            audio_thread.start()
            
            # Wait a bit for the audio loop to initialize
            import time
            time.sleep(1)
        
        # Process audio data (this is where you'd integrate with your AI)
        # For now, send a mock response
        emit('ai_response', {
            'type': 'text',
            'data': 'I heard your voice input. This is a test response from Dr. Swatantra AI.',
            'timestamp': threading.current_thread().name
        })
        
        # You can also send audio response
        # emit('audio_response', {
        #     'type': 'audio',
        #     'data': base64_encoded_audio_data
        # })
        
    except Exception as e:
        logger.error(f"Error handling audio: {str(e)}")
        emit('error', {'message': f'Audio processing error: {str(e)}'})

@socketio.on('streaming_control')
def handle_streaming_control(data):
    """Handle streaming control signals"""
    try:
        action = data.get('action', 'unknown')
        logger.info(f"Streaming control: {action} from client {request.sid}")
        
        if action == 'start':
            emit('streaming_status', {
                'status': 'started',
                'message': 'Voice streaming started'
            })
        elif action == 'stop':
            emit('streaming_status', {
                'status': 'stopped', 
                'message': 'Voice streaming stopped'
            })
            
    except Exception as e:
        logger.error(f"Error handling streaming control: {str(e)}")
        emit('error', {'message': f'Streaming control error: {str(e)}'})

@socketio.on('stop_streaming')
def handle_stop_streaming(data):
    """Handle stop streaming request"""
    try:
        logger.info(f"Stop streaming request from client {request.sid}")
        
        # Stop the audio loop for this client
        global current_audio_loop
        if current_audio_loop:
            asyncio.run(current_audio_loop.stop())
            current_audio_loop = None
            
        emit('streaming_status', {
            'status': 'stopped',
            'message': 'Voice streaming stopped successfully'
        })
        
    except Exception as e:
        logger.error(f"Error stopping streaming: {str(e)}")
        emit('error', {'message': f'Stop streaming error: {str(e)}'})

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)