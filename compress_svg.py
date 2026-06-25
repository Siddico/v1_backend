import re
import base64
from io import BytesIO
# pyrefly: ignore [missing-import]
from PIL import Image
import os

def compress_embedded_b64(filepath):
    print(f'Processing {filepath}')
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find base64 image tags
    # The regex looks for href="data:image/xyz;base64,....."
    matches = re.finditer(r'href="data:image/(jpeg|png);base64,([^"]+)"', content)
    
    new_content = content
    for match in matches:
        fmt = match.group(1)
        b64_data = match.group(2)
        
        try:
            img_data = base64.b64decode(b64_data)
            img = Image.open(BytesIO(img_data))
            if img.mode in ('RGBA', 'P'):
                img = img.convert('RGB')
            
            # thumbnail to reduce dimensions
            img.thumbnail((800, 800), Image.Resampling.LANCZOS)
            
            out_buffer = BytesIO()
            img.save(out_buffer, format='JPEG', quality=75, optimize=True)
            compressed_b64 = base64.b64encode(out_buffer.getvalue()).decode('utf-8')
            
            old_str = f'href="data:image/{fmt};base64,{b64_data}"'
            new_str = f'href="data:image/jpeg;base64,{compressed_b64}"'
            
            new_content = new_content.replace(old_str, new_str)
            print(f'Compressed embedded image from {len(b64_data)} to {len(compressed_b64)} chars')
        except Exception as e:
            print(f'Error processing embedded image: {e}')
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f'Finished {filepath}')

compress_embedded_b64('assets/images/man_dr.svg')
compress_embedded_b64('assets/images/woman_dr.svg')
