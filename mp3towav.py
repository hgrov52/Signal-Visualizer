from pydub import AudioSegment
sound = AudioSegment.from_mp3("/home/groveh/Documents/Music Visualizer/song.mp3")
sound.export("./song.wav", format="wav")
