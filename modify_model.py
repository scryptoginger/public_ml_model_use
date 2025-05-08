import json

# Edit the model's config.json
config_path = "./model/config.json"

with open(config_path, "r") as f:
	config = json.load(f)

config["modified_by_user"] = True

with open(config_path, "w") as f:
	json.dump(config, f, indent=2)

print("Added 'modified_by_user' flag to config.json")

# Add a custom note file
with open("./model/custom_note.txt", "w") as f:
	f.write("User-added metadata or note for this model.\n")

print("Added custom_note.txt to model directory.")