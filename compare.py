import json
import sys

def extract(items, prefix=""):
    res = {}
    for item in items:
        if 'item' in item:
            res.update(extract(item['item'], prefix + item['name'] + ' -> '))
        elif 'request' in item:
            req = item['request']
            method = req['method']
            url = req['url']['raw'] if isinstance(req['url'], dict) else (req['url'] if isinstance(req['url'], str) else "")
            res[prefix + item['name']] = f"{method} {url}"
    return res

with open("BrainGuard API.postman_collection.json", encoding="utf-8") as f1:
    d1 = json.load(f1)
with open("BrainGuard API.postman_collection_lv.json", encoding="utf-8") as f2:
    d2 = json.load(f2)

old_eps = extract(d1.get('item', []))
new_eps = extract(d2.get('item', []))

print("NEW ENDPOINTS:")
for k, v in new_eps.items():
    if k not in old_eps:
        print(f"{k}: {v}")
    elif old_eps[k] != v:
        print(f"CHANGED ENDPOINT: {k}: old={old_eps[k]}, new={v}")
