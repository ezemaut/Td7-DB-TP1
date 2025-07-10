import re
import csv
from pathlib import Path
from collections import defaultdict

# Ruta del archivo SQL
sql_path = '02 Datos.sql'  # Cambiar si es necesario

# Leer el contenido del archivo
with open(sql_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Expresión regular para encontrar los INSERT
pattern = re.compile(
    r"INSERT INTO (\w+)\s*\(([^)]+)\)\s*VALUES\s*(\([^;]+?\));",
    re.IGNORECASE | re.MULTILINE
)

# Diccionario para almacenar datos por tabla
tables = defaultdict(lambda: {'columns': [], 'rows': []})

# Procesar cada match
for match in pattern.finditer(content):
    table = match.group(1)
    columns = [col.strip() for col in match.group(2).split(',')]
    values_group = match.group(3)

    # Puede haber múltiples tuplas de valores: (...), (...), ...
    values_matches = re.findall(r'\(([^)]+)\)', values_group)
    
    for val in values_matches:
        # Maneja comillas y números correctamente
        vals = [v.strip().strip("'") if v.strip().startswith("'") else v.strip() for v in val.split(',')]
        tables[table]['columns'] = columns
        tables[table]['rows'].append(vals)

# Escribir cada tabla a un archivo CSV
output_dir = Path('./csv_output')
output_dir.mkdir(exist_ok=True)

for table_name, data in tables.items():
    csv_file = output_dir / f"{table_name}.csv"
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(data['columns'])
        writer.writerows(data['rows'])

print(f"Archivos CSV generados en: {output_dir.resolve()}")
