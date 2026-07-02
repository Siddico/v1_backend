import json
import shutil
import sys

filename = "BrainGuard_API_postman_collection.json"
backup_filename = "BrainGuard_API_postman_collection_backup.json"
shutil.copyfile(filename, backup_filename)

with open(filename, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Define subfolders and the exact substrings to match the request name
# We will use lowercase for matching
grouping = {
    "Auth": {
        "Authentication": ["register", "login", "get me", "logout"],
        "Password & Verification": ["otp", "reset"]
    },
    "Patient": {
        "Profile & Settings": ["profile", "qr scan"],
        "Health & Medical Data": ["health data", "signal", "radiology"],
        "AI & Predictions": ["predict", "prediction", "questionnaire"],
        "Notifications & Emergency": ["notification", "emergency", "report"],
        "Chat & Communications": ["chat", "chatbot"],
        "Appointments": ["appointment"],
        "Medications": ["medication"],
        "Relationships": ["relationship"]
    },
    "Doctor": {
        "Profile & Discovery": ["doctor profile", "all doctors", "specialty"],
        "Patient Management": ["patient list", "add patient", "scan patient qr", "single patient"],
        "Alerts & Follow-ups": ["alert", "follow-up"],
        "Medical Records": ["medical data", "lab document", "radiology"],
        "Chat & Communications": ["chat"],
        "Appointments": ["appointment"],
        "Relationships": ["relationship"]
    },
    "Researcher": {
        "Profile & Alerts": ["profile", "alert"],
        "Papers & Research": ["paper"]
    }
}

def find_subfolder(item_name, folder_name):
    if folder_name not in grouping:
        return None
    name_lower = item_name.lower()
    for sub_name, keywords in grouping[folder_name].items():
        for keyword in keywords:
            if keyword in name_lower:
                return sub_name
    return "Other Endpoints"

new_items = []
for folder in data.get("item", []):
    if "item" not in folder:
        # Not a folder, keep as is
        new_items.append(folder)
        continue
    
    folder_name = folder.get("name")
    if folder_name not in grouping:
        new_items.append(folder)
        continue
    
    # It is a folder we want to organize
    subfolders_dict = {}
    
    for item in folder["item"]:
        subfolder_name = find_subfolder(item.get("name", ""), folder_name)
        if subfolder_name not in subfolders_dict:
            subfolders_dict[subfolder_name] = []
        subfolders_dict[subfolder_name].append(item)
    
    # Reconstruct folder item array
    new_sub_items = []
    
    # Keep specific order for subfolders based on grouping dict, then add others
    for sub_name in grouping[folder_name].keys():
        if sub_name in subfolders_dict and len(subfolders_dict[sub_name]) > 0:
            new_sub_items.append({
                "name": sub_name,
                "item": subfolders_dict[sub_name]
            })
            
    if "Other Endpoints" in subfolders_dict and len(subfolders_dict["Other Endpoints"]) > 0:
        # Instead of 'Other Endpoints' folder, just put them directly under the main folder, or in 'Other Endpoints'
        new_sub_items.append({
            "name": "Other Endpoints",
            "item": subfolders_dict["Other Endpoints"]
        })
        
    folder["item"] = new_sub_items
    new_items.append(folder)

data["item"] = new_items

with open(filename, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print("Reorganization complete!")
