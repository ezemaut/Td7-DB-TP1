# Part 1: Imports and Initialization

from faker import Faker
import random

# Initialize Faker with a seed for reproducibility
fake = Faker()
Faker.seed(42)  # You can change the seed for different results
random.seed(42)  # Ensuring that the random library is also seeded

# Helper function to generate SQL INSERT statements and write them to a file
import datetime

def write_insert_to_file(table_name, data, file_path):
    with open(file_path, 'a', encoding='utf-8') as f:
        for row in data:
            columns = ', '.join(row.keys())
            values = []
            for value in row.values():
                if isinstance(value, str):
                    values.append(f"'{value}'")
                elif isinstance(value, (datetime.date, datetime.datetime)):
                    # Format as full datetime string
                    values.append(f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'")
                elif value is None:
                    values.append("NULL")
                else:
                    values.append(str(value))
            values_str = ', '.join(values)
            insert_stmt = f"INSERT INTO {table_name} ({columns}) VALUES ({values_str});\n"
            f.write(insert_stmt)


# Part 2: Table Creation



# Generate data for Pais
def generate_pais_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "ID_pais": i,
            "Nombre": fake.country()
        }
        data.append(row)
    return data

# Generate data for Provincia
def generate_provincia_table(paises, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "ID_provincia": i,
            "Nombre": fake.state(),
            "ID_pais": random.choice(paises)["ID_pais"]
        }
        data.append(row)
    return data

# Generate data for Localidad
def generate_localidad_table(provincias, num_rows=15):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "ID_ciudad": i,
            "Nombre": fake.city(),
            "ID_provincia": random.choice(provincias)["ID_provincia"]
        }
        data.append(row)
    return data

# Generate data for Calle
def generate_calle_table(ciudades, num_rows=20):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "ID_calle": i,
            "Nombre": fake.street_name(),
            "CP": fake.postcode(),
            "ID_ciudad": random.choice(ciudades)["ID_ciudad"]
        }
        data.append(row)
    return data

# Generate data for Domicilio
def generate_domicilio_table(callles, num_rows=30):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "id_dom": i,
            "numero": fake.building_number(),
            "piso": random.randint(0, 10),
            "ID_calle": random.choice(callles)["ID_calle"]
        }
        data.append(row)
    return data

# Empresa table - references Domicilio
def generate_empresa_table(domicilios, num_rows=5):
    data = []
    selected_domicilios = random.sample(domicilios, num_rows)
    for dom in selected_domicilios:
        row = {
            "cuit": fake.unique.ein(),
            "razon_social": fake.company(),
            "id_dom": dom["id_dom"]
        }
        data.append(row)
    return data

# Ranking table
def generate_ranking_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "id_ranking": i,
            "peso_imp": random.randint(1, 10)
        }
        data.append(row)
    return data

# Categoria table - references Ranking
def generate_categoria_table(rankings):
    # Predefined list of normal category names
    categoria_names = ["Bronze", "Silver", "Gold", "Platinum", "Diamond"]
    
    data = []
    
    for i, r in enumerate(rankings):
        if i < len(categoria_names):  # Ensure we do not run out of predefined names
            categoria_name = categoria_names[i]
        
            row = {
                "nombre_cat": categoria_name,
                "min_total_anual": round(random.uniform(1000, 10000), 2),
                "promedio_mensual": round(random.uniform(100, 1000), 2),
                "id_ranking": r["id_ranking"]
            }
            data.append(row)
    
    return data


def generate_promocion_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        # Generate start and end datetime with random hour, minute, second
        start_date = fake.date_time_this_year()  # Generates datetime with random time
        end_date = fake.date_time_between(start_date=start_date, end_date="+30d")  # Generates datetime within a range

        row = {
            "ID_promocion": i,
            "fecha_inicio": start_date,
            "fecha_fin": end_date,
            "descuento": random.randint(5, 50)
        }
        data.append(row)
    return data


# Caracteristica table
def generate_caracteristica_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "id_caracteristica": i,
            "nombre_atraccion": fake.word().capitalize(),
            "altura_min": random.randint(100, 200),
            "edad_min": random.randint(5, 18)
        }
        data.append(row)
    return data

# Titular table - references Domicilio
def generate_titular_table(domicilios, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "DNI": fake.unique.random_int(min=10000000, max=99999999),
            "Nombre": fake.first_name(),
            "Apellido": fake.last_name(),
            "Celular": fake.phone_number(),
            "id_dom": random.choice(domicilios)["id_dom"]
        }
        data.append(row)
    return data

# Tarjeta table - references Titular
def generate_tarjeta_table(titulares):
    data = []
    for i, titular in enumerate(titulares, 1):
        row = {
            "ID_tarjeta": i,
            "foto": fake.image_url(),
            "estado": fake.boolean(),
            "Total_gastado": round(random.uniform(0, 5000), 2),
            "DNI": titular["DNI"]
        }
        data.append(row)
    return data

# Medio_de_Pago table
def generate_medio_pago_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "id_medio": i,
            "banco": fake.company(),
            "tipo": random.choice(["Crédito", "Débito", "Transferencia"])
        }
        data.append(row)
    return data

# Factura table - references Titular and Medio_de_Pago
def generate_factura_table(titulares, medios_pago, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        fecha_emision = fake.date_time_this_year()
        fecha_vencimiento = fake.date_between(start_date=fecha_emision, end_date="+30d")
        row = {
            "Nro_factura": i,
            "fecha_emision": fecha_emision,
            "fecha_vencimiento": fecha_vencimiento,
            "importe_total": round(random.uniform(100, 1000), 2),
            "pagado": fake.boolean(),
            "DNI": random.choice(titulares)["DNI"],
            "id_medio_pago": random.choice(medios_pago)["id_medio"]
        }
        data.append(row)
    return data

# Entretenimiento table - references Categoria
def generate_entretenimiento_table(categorias, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        fecha = fake.date_time_this_year()
        row = {
            "id_entretenimiento": i,
            "fecha": fecha,
            "nombre": fake.company(),
            "precio": round(random.uniform(20, 200), 2),
            "tipo": random.choice(["Evento", "Parque"]),
            "min_categoria": random.choice(categorias)["nombre_cat"]
        }
        data.append(row)
    return data

# Parque_de_Diversiones table - subset of Entretenimiento
def generate_parque_table(entretenimientos):
    parques = [e for e in entretenimientos if e["tipo"] == "Parque"]
    data = []
    for p in parques:
        row = {
            "id_entretenimiento": p["id_entretenimiento"],
            "fecha": p["fecha"]
        }
        data.append(row)
    return data

# Evento table - subset of Entretenimiento + references Empresa
def generate_evento_table(entretenimientos, empresas):
    eventos = [e for e in entretenimientos if e["tipo"] == "Evento"]
    data = []
    for e in eventos:
        fecha_inicio = e["fecha"]
        fecha_fin = fake.date_between(start_date=fecha_inicio, end_date="+15d")
        row = {
            "id_entretenimiento": e["id_entretenimiento"],
            "fecha": e["fecha"],
            "fecha_inicio": fecha_inicio,
            "fecha_fin": fecha_fin,
            "cuit": random.choice(empresas)["cuit"]
        }
        data.append(row)
    return data

# Atraccion table - references Caracteristica and Parque_de_Diversiones
def generate_atraccion_table(caracteristicas, parques, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        parque = random.choice(parques)
        row = {
            "id_atraccion": i,
            "fecha": fake.date_time_this_year(),
            "precio": round(random.uniform(15, 150), 2),
            "id_caracteristica": random.choice(caracteristicas)["id_caracteristica"],
            "id_parque": parque["id_entretenimiento"],
            "fecha_parque": parque["fecha"]
        }
        data.append(row)
    return data

# Linea_Factura: links Factura, Tarjeta, Entretenimiento, Atraccion
def generate_linea_factura_table(facturas, tarjetas, entretenimientos, atracciones, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        factura = random.choice(facturas)
        tarjeta = random.choice(tarjetas)
        entretenimiento = random.choice(entretenimientos)
        atraccion = random.choice(atracciones)
        row = {
            "id_linea": i,
            "fecha_de_consumo": fake.date_between(start_date='-1y', end_date='today'),
            "monto": round(random.uniform(30, 300), 2),
            "nro_factura": factura["Nro_factura"],
            "id_tarjeta": tarjeta["ID_tarjeta"],
            "id_entretenimiento": entretenimiento["id_entretenimiento"],
            "fecha_entret": entretenimiento["fecha"],
            "id_atraccion": atraccion["id_atraccion"],
            "fecha_atraccion": atraccion["fecha"]
        }
        data.append(row)
    return data

# HistorialCategoria: links Tarjeta and Categoria
def generate_historial_categoria_table(tarjetas, categorias, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        tarjeta = random.choice(tarjetas)
        categoria = random.choice(categorias)
        row = {
            "id_historial": i,
            "fecha_de_inicio": fake.date_between(start_date='-2y', end_date='today'),
            "ID_tarjeta": tarjeta["ID_tarjeta"],
            "nombre_cat": categoria["nombre_cat"]
        }
        data.append(row)
    return data


# Promocion_Atraccion: many-to-many between Promocion and Atraccion
def generate_promocion_atraccion_table(promos, atracciones, num_rows=10):
    data = []
    selected_combinations = set()  # To keep track of used combinations

    for _ in range(num_rows):
        while True:
            promo = random.choice(promos)
            atrac = random.choice(atracciones)

            # Ensure unique combination of promo and atrac
            combo = (promo["ID_promocion"], atrac["id_atraccion"])
            if combo not in selected_combinations:
                selected_combinations.add(combo)
                row = {
                    "ID_promocion": promo["ID_promocion"],
                    "id_atraccion": atrac["id_atraccion"],
                    "fecha": atrac["fecha"]
                }
                data.append(row)
                break  # Exit the while loop once we have a unique combination

    return data

# Promocion_Entret: many-to-many between Promocion and Entretenimiento
def generate_promo_entret_table(promos, entretenimientos, num_rows=10):
    data = []
    selected_combinations = set()  # To keep track of used combinations

    for _ in range(num_rows):
        while True:
            promo = random.choice(promos)
            entret = random.choice(entretenimientos)
            
            # Ensure unique combination of promo and entret
            combo = (promo["ID_promocion"], entret["id_entretenimiento"])
            if combo not in selected_combinations:
                selected_combinations.add(combo)
                row = {
                    "ID_promocion": promo["ID_promocion"],
                    "id_entretenimiento": entret["id_entretenimiento"],
                    "fecha": entret["fecha"]
                }
                data.append(row)
                break  # Exit the while loop once we have a unique combination

    return data

# cat_promo: many-to-many between Categoria and Promocion
def generate_cat_promo_table(categorias, promos, num_rows=10):
    data = []
    selected_combinations = set()  # To keep track of used combinations

    for _ in range(num_rows):
        while True:
            categoria = random.choice(categorias)
            promo = random.choice(promos)

            # Ensure unique combination of categoria and promo
            combo = (categoria["nombre_cat"], promo["ID_promocion"])
            if combo not in selected_combinations:
                selected_combinations.add(combo)
                row = {
                    "nombre_cat": categoria["nombre_cat"],
                    "ID_promocion": promo["ID_promocion"]
                }
                data.append(row)
                break  # Exit the while loop once we have a unique combination

    return data



# Part 3: SQL Making (Iterative Version)

def generate_sql_for_tables():
    open("generated_data.sql", "w").close()

    # --- Batch 1 ---
    pais_data = generate_pais_table(num_rows=5)
    write_insert_to_file("Pais", pais_data, "generated_data.sql")

    provincia_data = generate_provincia_table(pais_data, num_rows=10)
    write_insert_to_file("Provincia", provincia_data, "generated_data.sql")

    localidad_data = generate_localidad_table(provincia_data, num_rows=15)
    write_insert_to_file("Localidad", localidad_data, "generated_data.sql")

    calle_data = generate_calle_table(localidad_data, num_rows=20)
    write_insert_to_file("Calle", calle_data, "generated_data.sql")

    domicilio_data = generate_domicilio_table(calle_data, num_rows=30)
    write_insert_to_file("Domicilio", domicilio_data, "generated_data.sql")

    # --- Batch 2 ---
    empresa_data = generate_empresa_table(domicilio_data, num_rows=5)
    write_insert_to_file("Empresa", empresa_data, "generated_data.sql")

    ranking_data = generate_ranking_table(num_rows=5)
    write_insert_to_file("Ranking", ranking_data, "generated_data.sql")

    categoria_data = generate_categoria_table(ranking_data)
    write_insert_to_file("Categoria", categoria_data, "generated_data.sql")

    promocion_data = generate_promocion_table(num_rows=5)
    write_insert_to_file("Promocion", promocion_data, "generated_data.sql")

    caracteristica_data = generate_caracteristica_table(num_rows=5)
    write_insert_to_file("Caracteristica", caracteristica_data, "generated_data.sql")

    titular_data = generate_titular_table(domicilio_data, num_rows=10)
    write_insert_to_file("Titular", titular_data, "generated_data.sql")

    tarjeta_data = generate_tarjeta_table(titular_data)
    write_insert_to_file("Tarjeta", tarjeta_data, "generated_data.sql")

    medio_pago_data = generate_medio_pago_table(num_rows=5)
    write_insert_to_file("Medio_de_Pago", medio_pago_data, "generated_data.sql")

    factura_data = generate_factura_table(titular_data, medio_pago_data, num_rows=10)
    write_insert_to_file("Factura", factura_data, "generated_data.sql")

        # --- Batch 3 ---
    entretenimiento_data = generate_entretenimiento_table(categoria_data, num_rows=10)
    write_insert_to_file("Entretenimiento", entretenimiento_data, "generated_data.sql")

    parque_data = generate_parque_table(entretenimiento_data)
    write_insert_to_file("Parque_de_Diversiones", parque_data, "generated_data.sql")

    evento_data = generate_evento_table(entretenimiento_data, empresa_data)
    write_insert_to_file("Evento", evento_data, "generated_data.sql")

    atraccion_data = generate_atraccion_table(caracteristica_data, parque_data, num_rows=10)
    write_insert_to_file("Atraccion", atraccion_data, "generated_data.sql")

        # --- Batch 4 ---
    linea_factura_data = generate_linea_factura_table(factura_data, tarjeta_data, entretenimiento_data, atraccion_data, num_rows=10)
    write_insert_to_file("Linea_Factura", linea_factura_data, "generated_data.sql")

    historial_categoria_data = generate_historial_categoria_table(tarjeta_data, categoria_data, num_rows=10)
    write_insert_to_file("HistorialCategoria", historial_categoria_data, "generated_data.sql")

    promocion_atraccion_data = generate_promocion_atraccion_table(promocion_data, atraccion_data, num_rows=10)
    write_insert_to_file("Promocion_Atraccion", promocion_atraccion_data, "generated_data.sql")

    promo_entret_data = generate_promo_entret_table(promocion_data, entretenimiento_data, num_rows=10)
    write_insert_to_file("Promo_Entret", promo_entret_data, "generated_data.sql")

    cat_promo_data = generate_cat_promo_table(categoria_data, promocion_data, num_rows=10)
    write_insert_to_file("cat_promo", cat_promo_data, "generated_data.sql")



generate_sql_for_tables()