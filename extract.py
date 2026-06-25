import json
d = json.load(open('BrainGuard API.postman_collection_lv.json', encoding='utf-8'))
def extract_reqs(items):
    res = []
    for i in items:
        if 'item' in i:
            res.extend(extract_reqs(i['item']))
        elif 'request' in i:
            res.append(i)
    return res
reqs = extract_reqs(d.get('item', []))
for r in reqs:
    name = r['name']
    if 'otp' in name.lower() or 'reset' in name.lower():
        url = r['request']['url']['raw'] if 'url' in r['request'] and 'raw' in r['request']['url'] else r['request'].get('url')
        print(f"Name: {name}\nURL: {url}")
        print(f"Body: {json.dumps(r['request'].get('body', {}), indent=2)}\n")
