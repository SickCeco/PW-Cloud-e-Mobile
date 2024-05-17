import os
import json
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service

# Imposta il percorso di chromedriver
chromedriver_path = "/Users/francesco/scrivania/chromedriver"

# Crea un'istanza del servizio Chrome
service = Service(executable_path=chromedriver_path)

# Inizializza il browser come un'istanza di webdriver.Chrome
browser = webdriver.Chrome(service=service)
browser.implicitly_wait(10)  # Attende fino a 10 secondi se un elemento non è immediatamente disponibile

def get_transcript(browser, my_tedx):
    try:
        browser.get(my_tedx['url'] + '/transcript')
        # transcript non esiste
        if browser.title == "TED | 404: Not Found":
            raise Exception('Transcript not available')
        
        script_tag = browser.find_element(By.XPATH, "//script[@type='application/ld+json']")
        script_content = script_tag.get_attribute('innerHTML')
        script_json = json.loads(script_content)
        
        transcript_text = script_json.get('transcript', None)
        if not transcript_text:
            raise Exception('Transcript not found in the JSON script')
        
        transcript = []
        for line in transcript_text.split('\n'):
            sentence = line.strip()
            if sentence:
                transcript.append(sentence)
        
        my_tedx['transcript'] = transcript
    except Exception as err:
        print(f"Error for URL {my_tedx['url']}: {err}")
        my_tedx['transcript'] = []

    return my_tedx

# Funzione per ottenere la trascrizione e salvarla per ogni TEDx
def fetch_transcriptions(input_file, output_file, missing_file):
    # Leggi il file CSV con i dati
    data = pd.read_csv(input_file)

    all_transcripts = []
    missing_transcripts = []

    # Loop attraverso ogni riga del DataFrame
    for index, row in data.iterrows():
        my_tedx = {'id': row['id'], 'url': row['url']}
        transcript = get_transcript(browser, my_tedx)
        if transcript['transcript']:
            all_transcripts.append({'id': my_tedx['id'], 'transcript': " ".join(transcript['transcript'])})
            print(f"Transcript saved for the ID {my_tedx['id']}.")
        else:
            print(f"No transcript found for the ID {my_tedx['id']}.")
            missing_transcripts.append({'id': my_tedx['id']})

    # Controlla se ci sono trascrizioni da salvare
    if all_transcripts:
        transcript_df = pd.DataFrame(all_transcripts)
        transcript_df.to_csv(output_file, index=False)
        print(f"All transcripts saved to {output_file}.")
    else:
        print("No transcripts were found to save.")
    
    # Salva gli ID mancanti nel file missing_transcripts.csv
    if missing_transcripts:
        missing_df = pd.DataFrame(missing_transcripts)
        missing_df.to_csv(missing_file, index=False)
        print(f"Missing transcripts saved to {missing_file}.")
    else:
        print("No missing transcripts were found to save.")

# Utilizzo della funzione
input_file_path = os.path.join("/Users/francesco/scrivania/Dataset", "final_list.csv")
output_file_path = os.path.join("/Users/francesco/scrivania/Transcriptions", "transcript_dataset.csv")
missing_file_path = os.path.join("/Users/francesco/scrivania/Transcriptions", "missing_transcripts.csv")
fetch_transcriptions(input_file_path, output_file_path, missing_file_path)

# Chiudi il browser alla fine
browser.quit()
