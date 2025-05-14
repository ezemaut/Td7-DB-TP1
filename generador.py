# Part 1: Imports and Initialization

from faker import Faker
import random
from collections import defaultdict
from datetime import datetime, timedelta


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


# ----- 1. INDEPENDENT TABLES -----
def generate_ranking_table(num_rows=5):
    return [{"id_ranking": i, "peso_imp": i} for i in range(1, num_rows + 1)]

def generate_empresa_table(domicilio_data, num_rows=5):
    empresas = []

    for i in range(1, num_rows + 1):
        # Generate a unique cuit for the company (simulating a CUIT format)
        cuit = f"20{random.randint(1000000000, 9999999999)}"  # Example CUIT format: 20XXXXXXXXXX

        # Choose a random domicilio
        domicilio = random.choice(domicilio_data)
        id_domicilio = domicilio["id_dom"]

        # Generate company data
        empresa = {
            "CUIT": cuit,
            "razon_social": fake.company(),
            "id_dom": id_domicilio
        }

        empresas.append(empresa)

    return empresas

# ----- 2. FIRST-LEVEL DEPENDENTS -----
def generate_categoria_table(rankings):
    categoria_names = ["Bronze", "Silver", "Gold", "Platinum", "Diamond"]
    random.shuffle(categoria_names)
    return [{
        "nombre_cat": categoria_names[i],
        "min_total_anual": round(random.uniform(1000, 10000), 2),
        "promedio_mensual": round(random.uniform(100, 1000), 2),
        "id_ranking": rankings[i % len(rankings)]["id_ranking"]
    } for i in range(len(categoria_names))]

def generate_promocion_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        start_date = fake.date_time_this_year()
        end_date = start_date + timedelta(days=random.randint(1, 30))
        data.append({
            "id_promocion": i,
            "fecha_inicio": start_date,
            "fecha_fin": end_date,
            "descuento": random.randint(5, 50)
        })
    return data

def generate_tarjeta_table(titulares, num_rows=10):
    tarjetas = []
    
    for i in range(1, num_rows + 1):
        titular = random.choice(titulares)  # Randomly pick a Titular
        id_tarjeta = i
        
        # Calculate total_gastado for this tarjeta by referencing the tarjeta_totals dictionary

        tarjetas.append({
            "id_tarjeta": id_tarjeta,
            "foto": fake.image_url(),
            "estado": random.choice([True, False]),  # Random boolean for 'estado'
            "Total_gastado": -1,  # Use the calculated total_gastado
            "DNI": titular["DNI"],  # Foreign Key: linking to Titular
        })
    
    return tarjetas




# ----- 3. MID-LEVEL DEPENDENTS -----
def generate_entretenimiento_table(categorias, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        fecha = fake.date_time_this_year()
        data.append({
            "id_entretenimiento": i,
            "fecha": fecha,
            "nombre": fake.company() + " Event",
            "precio": round(random.uniform(20, 200), 2),
            "tipo": random.choice(["Evento", "Parque"]),
            "min_categoria": random.choice(categorias)["nombre_cat"]
        })
    return data

# Generate Factura table
def generate_factura_table(titulares, medio_pago, tarjetas, num_rows=10):
    data = []
    facturas_por_tarjeta = defaultdict(list)

    # Build a set of DNIs that have at least one tarjeta
    dnis_con_tarjeta = {t["DNI"] for t in tarjetas}

    # Filter titulares to only those who have a tarjeta
    titulares_con_tarjeta = [titular for titular in titulares if titular["DNI"] in dnis_con_tarjeta]

    for i in range(1, num_rows + 1):
        if not titulares_con_tarjeta:
            break  # Stop if no eligible titular remains

        titular = random.choice(titulares_con_tarjeta)
        medio = random.choice(medio_pago)
        fecha_emision = fake.date_time_this_year()
        fecha_vencimiento = fake.date_this_year()
        pagado = random.choice([True, False])

        row = {
            "Nro_factura": i,
            "fecha_emision": fecha_emision,
            "fecha_vencimiento": fecha_vencimiento,
            "importe_total": 0,
            "pagado": pagado,
            "DNI": titular["DNI"],
            "id_medio_pago": medio["id_medio"]
        }

        data.append(row)
        facturas_por_tarjeta[titular["DNI"]].append(row)

    return data, facturas_por_tarjeta



def generate_linea_factura_table(facturas, tarjetas, entretenimientos, atracciones, promo_entret_table, promociones, num_rows=20):
    data = []
    linea_id = 1
    factura_totals = defaultdict(float)
    tarjeta_totals = defaultdict(float)

    # Group tarjetas by DNI
    tarjetas_por_dni = defaultdict(list)
    for tarjeta in tarjetas:
        tarjetas_por_dni[tarjeta["DNI"]].append(tarjeta)

    # Map promociones
    promociones_dict = {
        promo["id_promocion"]: {
            "fecha_inicio": promo["fecha_inicio"],
            "fecha_fin": promo["fecha_fin"],
            "descuento": promo["descuento"]
        }
        for promo in promociones
    }

    # Map entretenimiento -> promociones
    promo_entret_lookup = defaultdict(list)
    for pe in promo_entret_table:
        promo_entret_lookup[pe["id_entretenimiento"]].append(pe["id_promocion"])

    for _ in range(num_rows):
        factura = random.choice(facturas)
        dni = factura["DNI"]

        if dni not in tarjetas_por_dni:
            continue  # No tarjeta for this DNI

        tarjeta = random.choice(tarjetas_por_dni[dni])
        entret = random.choice(entretenimientos)

        precio = entret["precio"]
        fecha_consumo = entret["fecha"]
        descuento_total = 0

        # Apply discounts
        for promo_id in promo_entret_lookup[entret["id_entretenimiento"]]:
            promo = promociones_dict.get(promo_id)
            if promo and promo["fecha_inicio"] <= fecha_consumo <= promo["fecha_fin"]:
                descuento_total = max(descuento_total, promo["descuento"])

        precio_final = round(precio * (1 - descuento_total / 100), 2)

        # Pick random attraction
        atraccion = random.choice(atracciones) if atracciones else None
        id_atraccion = atraccion["id_atraccion"] if atraccion else None
        fecha_atraccion = atraccion["fecha"] if atraccion else None

        row = {
            "id_linea": linea_id,
            "fecha_de_consumo": fecha_consumo,
            "monto": precio_final,
            "nro_factura": factura["Nro_factura"],
            "id_tarjeta": tarjeta["id_tarjeta"],
            "id_entretenimiento": entret["id_entretenimiento"],
            "fecha_entret": entret["fecha"],
            "id_atraccion": id_atraccion,
            "fecha_atraccion": fecha_atraccion
        }

        data.append(row)
        factura_totals[factura["Nro_factura"]] += precio_final
        tarjeta_totals[tarjeta["id_tarjeta"]] += precio_final
        linea_id += 1

    # Update factura totals
    for factura in facturas:
        factura["importe_total"] = round(factura_totals[factura["Nro_factura"]], 2)

    return data, tarjeta_totals


def generate_promo_entret_table(promociones, entretenimientos, num_rows=10):
    data = []
    generated_combinations = set()  # Track unique combinations

    for _ in range(num_rows):
        # Generate random row data
        entretenimiento = random.choice(entretenimientos)
        promo_id = random.choice(promociones)["id_promocion"]
        entretenimiento_id = entretenimiento["id_entretenimiento"]
        fecha = entretenimiento["fecha"]
        
        # Check if the combination already exists
        while (promo_id, entretenimiento_id, fecha) in generated_combinations:
            promo_id = random.choice(promociones)["id_promocion"]

            entretenimiento = random.choice(entretenimientos)
            entretenimiento_id = entretenimiento["id_entretenimiento"]
            fecha = entretenimiento["fecha"]
        
        # Add the combination to the set and append the row to data
        generated_combinations.add((promo_id, entretenimiento_id, fecha))
        row = {
            "id_promocion": promo_id,
            "id_entretenimiento": entretenimiento_id,
            "fecha": fecha
        }
        data.append(row)
    
    return data



def generate_promocion_atraccion_table(promociones, atracciones, num_rows=10):
    data = []
    generated_combinations = set()  # Track unique combinations

    for _ in range(num_rows):
        # Generate random row data
        atraccion = random.choice(atracciones)
        promo_id = random.choice(promociones)["id_promocion"]
        atraccion_id = atraccion["id_atraccion"]
        fecha = atraccion["fecha"]

        # Check if the combination already exists
        while (promo_id, atraccion_id, fecha) in generated_combinations:
            promo_id = random.choice(promociones)["id_promocion"]
            atraccion = random.choice(atracciones)
            atraccion_id = atraccion["id_atraccion"]
            fecha = atraccion["fecha"]

        # Add the combination to the set and append the row to data
        generated_combinations.add((promo_id, atraccion_id, fecha))
        row = {
            "id_promocion": promo_id,
            "id_atraccion": atraccion_id,
            "fecha": fecha
        }
        data.append(row)

    return data



def generate_cat_promo_table(categorias, promociones, num_rows=10):
    data = []
    generated_combinations = set()  # Track unique combinations

    for _ in range(num_rows):
        # Generate random row data
        categoria = random.choice(categorias)
        promo_id = random.choice(promociones)["id_promocion"]
        categoria_name = categoria["nombre_cat"]

        # Check if the combination already exists
        while (categoria_name, promo_id) in generated_combinations:
            categoria_name = random.choice(categorias)["nombre_cat"]
            promo_id = random.choice(promociones)["id_promocion"]

        # Add the combination to the set and append the row to data
        generated_combinations.add((categoria_name, promo_id))
        row = {
            "nombre_cat": categoria_name,
            "id_promocion": promo_id
        }
        data.append(row)

    return data


def generate_historial_categoria_table(tarjetas, categorias, num_rows=10):
    data = []
    generated_combinations = set()  # Track unique combinations of ID_tarjeta, nombre_cat, fecha_de_inicio

    for _ in range(num_rows):
        # Generate random row data
        id_tarjeta = random.choice(tarjetas)["id_tarjeta"]
        nombre_cat = random.choice(categorias)["nombre_cat"]
        fecha_de_inicio = fake.date_this_decade()  # Generate random date within the current decade

        # Check if the combination of (id_tarjeta, nombre_cat, fecha_de_inicio) already exists
        while (id_tarjeta, nombre_cat, fecha_de_inicio) in generated_combinations:
            id_tarjeta = random.choice(tarjetas)["id_tarjeta"]
            nombre_cat = random.choice(categorias)["nombre_cat"]
            fecha_de_inicio = fake.date_this_decade()

        # Add the unique combination to the set and append the row to data
        generated_combinations.add((id_tarjeta, nombre_cat, fecha_de_inicio))
        row = {
            "id_historial": fake.unique.random_number(digits=6),  # Generate unique ID for historial
            "fecha_de_inicio": fecha_de_inicio,
            "ID_tarjeta": id_tarjeta,
            "nombre_cat": nombre_cat
        }
        data.append(row)

    return data


import random

def generate_atraccion_table(caracteristicas, parques, categorias, num_rows=10):
    data = []
    id_counter = 1

    for _ in range(num_rows):
        parque = random.choice(parques)

        row = {
            "id_atraccion": id_counter,
            "fecha": fake.date_time_this_year(),  # Same fecha as Parque
            "precio": round(random.uniform(500, 3000), 2),
            "id_caracteristica": random.choice(caracteristicas)["id_caracteristica"],
            "id_parque": parque["id_entretenimiento"],
            "fecha_parque": parque["fecha"],
            "min_categoria": random.choice(categorias)["nombre_cat"],  # Foreign key to Categoria
        }

        data.append(row)
        id_counter += 1

    return data



def generate_entretenimiento_table(categorias, domicilios, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        fecha = fake.date_time_this_year(before_now=False, after_now=True)
        nombre_tipo = random.choice(["Evento", "Parque"])
        nombre = (
            fake.city() + " Fest"
            if nombre_tipo == "Evento"
            else "Parque " + fake.first_name()
        )
        
        # Randomly select a Domicilio ID
        domicilio = random.choice(domicilios)

        row = {
            "id_entretenimiento": i,
            "fecha": fecha,
            "nombre": nombre,
            "precio": round(random.uniform(20, 200), 2),
            "tipo": nombre_tipo,
            "min_categoria": random.choice(categorias)["nombre_cat"],
            "id_domicilio": domicilio["id_dom"]  # Foreign key to Domicilio
        }
        
        data.append(row)
    return data

def generate_parque_table(entretenimientos):
    data = []
    for entret in entretenimientos:
        if entret["tipo"] == "Parque":
            row = {
                "id_entretenimiento": entret["id_entretenimiento"],
                "fecha": entret["fecha"],  # Referencing the 'fecha' from Entretenimiento
            }
            data.append(row)
    return data


def generate_evento_table(entretenimientos, empresas):
    data = []
    for entret in entretenimientos:
        if entret["tipo"] == "Evento":
            # Generate random start and end dates for the event
            fecha_inicio = fake.date_this_year(before_today=False)
            fecha_fin = fake.date_between(start_date=fecha_inicio, end_date="+1y")
            
            row = {
                "id_entretenimiento": entret["id_entretenimiento"],
                "fecha": entret["fecha"],  # Referencing the 'fecha' from Entretenimiento
                "fecha_inicio": fecha_inicio,
                "fecha_fin": fecha_fin,
                "cuit": random.choice(empresas)["CUIT"]
            }
            data.append(row)
    return data




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



# Titular table - references Domicilio
def generate_titular_table(domicilios, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
        row = {
            "DNI": fake.unique.random_int(min=38000000, max=50000000),
            "Nombre": fake.first_name(),
            "Apellido": fake.last_name(),
            "Celular": fake.phone_number(),
            "id_dom": random.choice(domicilios)["id_dom"]
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

def update_factura_totals(facturas, linea_facturas):
    factura_totals = defaultdict(float)

    for linea in linea_facturas:
        factura_totals[linea["nro_factura"]] += linea["monto"]

    for factura in facturas:
        nro = factura["Nro_factura"]
        factura["importe_total"] = round(factura_totals[nro], 2)

    return facturas

def calculate_tarjeta_totals(tarjeta_data, linea_facturas):
    tarjeta_totals = defaultdict(float)

    for linea in linea_facturas:
        tarjeta_id = linea["id_tarjeta"]
        monto = linea["monto"]
        tarjeta_totals[tarjeta_id] += monto

    for tarjeta in tarjeta_data:
        nro = tarjeta["id_tarjeta"]
        tarjeta["Total_gastado"] = round(tarjeta_totals[nro], 2)

    return tarjeta_totals


def generate_sql_for_tables():
    # Step 1: Generate Data
    pais_data = generate_pais_table(num_rows=5)
    provincia_data = generate_provincia_table(pais_data, num_rows=10)
    localidad_data = generate_localidad_table(provincia_data, num_rows=15)
    calle_data = generate_calle_table(localidad_data, num_rows=20)
    domicilio_data = generate_domicilio_table(calle_data, num_rows=30)
    empresa_data = generate_empresa_table(domicilio_data, num_rows=5)
    titular_data = generate_titular_table(domicilio_data, num_rows=10)
    medio_pago_data = generate_medio_pago_table(num_rows=5)
    ranking_data = generate_ranking_table(num_rows=5)
    categoria_data = generate_categoria_table(ranking_data)
    promocion_data = generate_promocion_table(num_rows=5)
    caracteristica_data = generate_caracteristica_table(num_rows=5)
    tarjeta_data = generate_tarjeta_table(titular_data, num_rows=10)
    factura_data, facturas_por_tarjeta = generate_factura_table(titular_data, medio_pago_data, tarjeta_data, num_rows=10)
    entretenimiento_data = generate_entretenimiento_table(categoria_data, domicilio_data, num_rows=10)
    parque_data = generate_parque_table(entretenimiento_data)
    evento_data = generate_evento_table(entretenimiento_data, empresa_data)
    atraccion_data = generate_atraccion_table(caracteristica_data, parque_data, categoria_data, num_rows=10)
    promo_entret_data = generate_promo_entret_table(promocion_data, entretenimiento_data, num_rows=10)
    promocion_atraccion_data = generate_promocion_atraccion_table(promocion_data, atraccion_data, num_rows=10)
    linea_factura_data, d = generate_linea_factura_table(factura_data, tarjeta_data, entretenimiento_data, atraccion_data, promo_entret_data, promocion_data, num_rows=20)
    historial_categoria_data = generate_historial_categoria_table(tarjeta_data, categoria_data, num_rows=10)
    cat_promo_data = generate_cat_promo_table(categoria_data, promocion_data, num_rows=10)

    # Step 2: Modify Tables that Need Updates or Dependencies
    # - Update factura totals
    # factura_data = update_factura_totals(factura_data, linea_factura_data)

    # - Calculate tarjeta totals
    tarjeta_totals = calculate_tarjeta_totals(tarjeta_data, linea_factura_data)

    # Step 3: Write SQL Statements
    open("generated_data.sql", "w").close()

    # Write the inserts for all tables
    write_insert_to_file("Pais", pais_data, "generated_data.sql")
    write_insert_to_file("Provincia", provincia_data, "generated_data.sql")
    write_insert_to_file("Localidad", localidad_data, "generated_data.sql")
    write_insert_to_file("Calle", calle_data, "generated_data.sql")
    write_insert_to_file("Domicilio", domicilio_data, "generated_data.sql")
    write_insert_to_file("Empresa", empresa_data, "generated_data.sql")
    write_insert_to_file("Titular", titular_data, "generated_data.sql")
    write_insert_to_file("Medio_de_Pago", medio_pago_data, "generated_data.sql")
    write_insert_to_file("Ranking", ranking_data, "generated_data.sql")
    write_insert_to_file("Categoria", categoria_data, "generated_data.sql")
    write_insert_to_file("Promocion", promocion_data, "generated_data.sql")
    write_insert_to_file("Caracteristica", caracteristica_data, "generated_data.sql")
    write_insert_to_file("Tarjeta", tarjeta_data, "generated_data.sql")
    write_insert_to_file("Factura", factura_data, "generated_data.sql")
    write_insert_to_file("Entretenimiento", entretenimiento_data, "generated_data.sql")
    write_insert_to_file("Parque_de_Diversiones", parque_data, "generated_data.sql")
    write_insert_to_file("Evento", evento_data, "generated_data.sql")
    write_insert_to_file("Atraccion", atraccion_data, "generated_data.sql")
    write_insert_to_file("Promo_Entret", promo_entret_data, "generated_data.sql")
    write_insert_to_file("Promocion_Atraccion", promocion_atraccion_data, "generated_data.sql")
    write_insert_to_file("Linea_Factura", linea_factura_data, "generated_data.sql")
    write_insert_to_file("HistorialCategoria", historial_categoria_data, "generated_data.sql")
    write_insert_to_file("cat_promo", cat_promo_data, "generated_data.sql")


generate_sql_for_tables()