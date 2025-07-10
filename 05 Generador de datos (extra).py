# Part 1: Imports and Initialization

from faker import Faker
import random
from collections import defaultdict
from datetime import datetime, timedelta
import calendar
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


# ----- 1. INDEPENDENT TABLES -----
def generate_ranking_table(num_rows=5):
    return [{"id_ranking": i, "peso_imp": i} for i in range(1, num_rows + 1)]

def generate_empresa_table(domicilio_data, num_rows=5):
    empresas = []

    # Ensure we don't try to sample more domicilios than available
    num_rows = min(num_rows, len(domicilio_data))
    
    # Sample unique domicilios without replacement
    selected_domicilios = random.sample(domicilio_data, num_rows)

    for i, domicilio in enumerate(selected_domicilios, start=1):
        # Generate a unique CUIT (you might want to validate uniqueness externally)
        cuit = f"20{random.randint(2000000000, 6000000000)}"

        empresa = {
            "CUIT": cuit,
            "razon_social": fake.company(),
            "id_dom": domicilio["id_dom"]
        }

        empresas.append(empresa)

    return empresas


# ----- 2. FIRST-LEVEL DEPENDENTS -----
def generate_categoria_table(rankings):
    categoria_names = ["Bronze", "Silver", "Gold", "Platinum", "Diamond"]
    return [{
        "nombre_cat": categoria_names[i],
        "min_total_anual": round(random.uniform(1000, 10000), 2),
        "promedio_mensual": round(random.uniform(100, 1000), 2),
        "id_ranking": rankings[i % len(rankings)]["id_ranking"]
    } for i in range(len(categoria_names))]

def generate_promocion_table(num_rows=5):
    data = []
    for i in range(1, num_rows + 1):
        start_date = fake.date_time_this_year() + timedelta(days=random.randint(20, 90))
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
    true_estado_assigned = set()  # Keep track of DNIs that have a True card assigned

    for i in range(1, num_rows + 1):
        titular = random.choice(titulares)
        dni = titular["DNI"]
        
        # Assign estado = True only if this DNI hasn't had a True yet
        if dni not in true_estado_assigned:
            estado = True
            true_estado_assigned.add(dni)
        else:
            estado = False

        tarjetas.append({
            "id_tarjeta": i,
            "foto": fake.image_url(),
            "estado": estado,
            "Total_gastado": -1,  # Placeholder, to be updated later
            "DNI": dni,
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

    # Generate a random emission date
    fecha_emision = fake.date_time_this_year()

    # Add 0 to 3 months manually
    months_to_add = random.randint(0, 3)
    year = fecha_emision.year
    month = fecha_emision.month + months_to_add

    # Adjust year and month if we go over December
    if month > 12:
        year += month // 12
        month = month % 12 or 12  # Handle month == 0 case

    # Get last day of the target month
    last_day = calendar.monthrange(year, month)[1]
    fecha_vencimiento = datetime.datetime(year, month, last_day)

    for i in range(1, num_rows + 1):
        if not titulares_con_tarjeta:
            break  # Stop if no eligible titular remains

        titular = random.choice(titulares_con_tarjeta)
        medio = random.choice(medio_pago)
        fecha_emision = fake.date_time_this_year()
        fecha_vencimiento = fake.date_between(start_date=fecha_emision, end_date="+1m")
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



def generate_linea_factura_table(
    facturas, tarjetas, entretenimientos, atracciones,
    promo_entret_table, promociones, lista_precio, num_rows=20
):
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

    # Group precios by entretenimiento and atracción
    precios_por_entret = defaultdict(list)
    precios_por_atracc = defaultdict(list)
    for lp in lista_precio:
        if lp["id_entretenimiento"] is not None:
            precios_por_entret[lp["id_entretenimiento"]].append(lp)
        elif lp["id_atraccion"] is not None:
            precios_por_atracc[lp["id_atraccion"]].append(lp)

    for _ in range(num_rows):
        factura = random.choice(facturas)
        dni = factura["DNI"]

        if dni not in tarjetas_por_dni:
            continue  # No tarjeta for this DNI

        tarjeta = random.choice(tarjetas_por_dni[dni])

        use_entret = (random.choice(["entret", "atrac"]) == "entret") or not atracciones

        if use_entret and entretenimientos:
            entret = random.choice(entretenimientos)
            precios = precios_por_entret.get(entret["id_entretenimiento"], [])
            if not precios:
                continue
            precio_row = random.choice(precios)



            # Calculate discount if applicable
            descuento_total = 0
            for promo_id in promo_entret_lookup.get(entret["id_entretenimiento"], []):
                promo = promociones_dict.get(promo_id)
                # Convert promo start and end to date if they are datetime
                start_date = promo["fecha_inicio"]
                end_date = promo["fecha_fin"]
                if start_date  <= end_date:
                    descuento_total = max(descuento_total, promo["descuento"])
                    
                if promo and promo["fecha_inicio"]  <= promo["fecha_fin"]:
                    descuento_total = max(descuento_total, promo["descuento"])

            precio_final = round(precio_row["precio"] * (1 - descuento_total / 100), 2)

            row = {
                "id_linea": linea_id,
                "fecha_de_consumo": precio_row["fecha"],
                "monto": precio_final,
                "nro_factura": factura["Nro_factura"],
                "id_tarjeta": tarjeta["id_tarjeta"],
                "id_entretenimiento": entret["id_entretenimiento"],
                "id_atraccion": None,
                "id_precio": precio_row["id_precio"]
            }

        elif atracciones:
            atr = random.choice(atracciones)
            precios = precios_por_atracc.get(atr["id_atraccion"], [])
            if not precios:
                continue
            precio_row = random.choice(precios)

            precio_final = precio_row["precio"]

            row = {
                "id_linea": linea_id,
                "fecha_de_consumo": precio_row["fecha"],
                "monto": precio_final,
                "nro_factura": factura["Nro_factura"],
                "id_tarjeta": tarjeta["id_tarjeta"],
                "id_entretenimiento": atr["id_parque"],  # assuming atraccion has id_entretenimiento
                "id_atraccion": atr["id_atraccion"],
                "id_precio": precio_row["id_precio"]
            }

        else:
            continue  # No valid data to create a row

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
        promo_id = random.choice(promociones)["id_promocion"]
        entretenimiento_id = random.choice(entretenimientos)["id_entretenimiento"]
        
        # Check if the combination already exists
        while (promo_id, entretenimiento_id) in generated_combinations:
            promo_id = random.choice(promociones)["id_promocion"]
            entretenimiento_id = random.choice(entretenimientos)["id_entretenimiento"]

        
        # Add the combination to the set and append the row to data
        generated_combinations.add((promo_id, entretenimiento_id))
        row = {
            "id_promocion": promo_id,
            "id_entretenimiento": entretenimiento_id,
        }
        data.append(row)
    
    return data



def generate_promocion_atraccion_table(promociones, atracciones, num_rows=10):
    data = []
    generated_combinations = set()  # Track unique combinations

    for _ in range(num_rows):
        # Generate random row data
        promo_id = random.choice(promociones)["id_promocion"]
        atraccion_id = random.choice(atracciones)["id_atraccion"]

        # Check if the combination already exists
        while (promo_id, atraccion_id) in generated_combinations:
            promo_id = random.choice(promociones)["id_promocion"]

            atraccion_id = random.choice(atracciones)["id_atraccion"]

        # Add the combination to the set and append the row to data
        generated_combinations.add((promo_id, atraccion_id))
        row = {
            "id_promocion": promo_id,
            "id_atraccion": atraccion_id,
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


def generate_atraccion_table(caracteristicas, parques, categorias, num_rows=10):
    data = []
    id_counter = 1

    adjectives = [
    "Mágico", "Vertiginoso", "Explosivo", "Misterioso", "Salvaje",
    "Intergaláctico", "Encantado", "Peligroso", "Legendario", "Fantástico"]

    nouns = [
        "Viaje", "Tornado", "Dragón", "Tren", "Caída", "Aventura",
        "Remolino", "Templo", "Desafío", "Laberinto"]

    for _ in range(num_rows):
        parque = random.choice(parques)

        row = {
            "id_atraccion": id_counter,
            "nombre_atraccion": f"{random.choice(adjectives)} {random.choice(nouns)}",
            "id_caracteristica": random.choice(caracteristicas)["id_caracteristica"],
            "id_parque": parque["id_entretenimiento"],
            "min_categoria": random.choice(categorias)["nombre_cat"],  # Foreign key to Categoria
        }

        data.append(row)
        id_counter += 1

    return data



def generate_entretenimiento_table(categorias, domicilios, num_rows=10):
    data = []
    for i in range(1, num_rows + 1):
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
            "nombre": nombre,
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
            }
            data.append(row)
    return data


def generate_evento_table(entretenimientos, empresas):
    data = []
    for entret in entretenimientos:
        if entret["tipo"] == "Evento":
            # Generate random start and end dates for the event
            fecha_inicio = fake.date_time_this_year() + timedelta(days=random.randint(20, 90))
            fecha_fin = fake.date_between(start_date=fecha_inicio, end_date="+1y")
            
            row = {
                "id_entretenimiento": entret["id_entretenimiento"],
                "fecha_inicio": fecha_inicio,
                "fecha_fin": fecha_fin,
                "cuit": random.choice(empresas)["CUIT"]
            }
            data.append(row)
    return data

def generate_lista_precio(entretenimiento_table, atraccion_table):
    data = []
    id_precio = 1

    # First, create at least one price for every entretenimiento
    for ent in entretenimiento_table:
        row = {
            "id_precio": id_precio,
            "precio": round(random.uniform(50, 150), 2),
            "fecha": fake.date_time_this_decade() + timedelta(days=random.randint(1, 30)),
            "id_entretenimiento": ent["id_entretenimiento"],
            "id_atraccion": None,
        }
        data.append(row)
        id_precio += 1

    # Then, create at least one price for every atraccion
    for atr in atraccion_table:
        row = {
            "id_precio": id_precio,
            "precio": round(random.uniform(5, 50), 2),
            "fecha": fake.date_time_this_decade() + timedelta(days=random.randint(1, 30)),
            "id_entretenimiento": None,
            "id_atraccion": atr["id_atraccion"]
        }
        data.append(row)
        id_precio += 1

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
            "altura_min": random.randint(100, 200),
            "edad_min": random.randint(5, 18)
        }
        data.append(row)
    return data

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
    pais_data = generate_pais_table(num_rows=10)
    provincia_data = generate_provincia_table(pais_data, num_rows=10)
    localidad_data = generate_localidad_table(provincia_data, num_rows=15)
    calle_data = generate_calle_table(localidad_data, num_rows=25)
    domicilio_data = generate_domicilio_table(calle_data, num_rows=40)
    empresa_data = generate_empresa_table(domicilio_data, num_rows=15)
    titular_data = generate_titular_table(domicilio_data, num_rows=20)
    medio_pago_data = generate_medio_pago_table(num_rows=5)
    ranking_data = generate_ranking_table(num_rows=5)
    categoria_data = generate_categoria_table(ranking_data)
    promocion_data = generate_promocion_table(num_rows=40)
    caracteristica_data = generate_caracteristica_table(num_rows=15)
    tarjeta_data = generate_tarjeta_table(titular_data, num_rows=25)
    factura_data, facturas_por_tarjeta = generate_factura_table(titular_data, medio_pago_data, tarjeta_data, num_rows=35)
    entretenimiento_data = generate_entretenimiento_table(categoria_data, domicilio_data, num_rows=50)
    parque_data = generate_parque_table(entretenimiento_data)
    evento_data = generate_evento_table(entretenimiento_data, empresa_data)
    atraccion_data = generate_atraccion_table(caracteristica_data, parque_data, categoria_data, num_rows=25)
    promo_entret_data = generate_promo_entret_table(promocion_data, entretenimiento_data, num_rows=50)
    promocion_atraccion_data = generate_promocion_atraccion_table(promocion_data, atraccion_data, num_rows=50)

    # Generate lista_precio ensuring every entretenimiento and atraccion has at least one price
    lista_precio_data = generate_lista_precio(entretenimiento_data, atraccion_data)

    linea_factura_data, tarjeta_totals = generate_linea_factura_table(
        factura_data, tarjeta_data,
        entretenimiento_data, atraccion_data,
        promo_entret_data, promocion_data,
        lista_precio_data,
        num_rows=100
    )
    
    historial_categoria_data = generate_historial_categoria_table(tarjeta_data, categoria_data, num_rows=40)
    cat_promo_data = generate_cat_promo_table(categoria_data, promocion_data, num_rows=20)

    # Step 2: Modify Tables that Need Updates or Dependencies
    # - Calculate tarjeta totals (already returned from linea_factura generation)
    tarjeta_totals = calculate_tarjeta_totals(tarjeta_data, linea_factura_data)  # Optional if recalculation needed

    # Step 3: Write SQL Statements
    open("generated_data.sql", "w")

    # Write inserts for all tables in proper order
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
    write_insert_to_file("Lista_Precio", lista_precio_data, "generated_data.sql")  # Insert prices before Linea_Factura
    write_insert_to_file("Promo_Entret", promo_entret_data, "generated_data.sql")
    write_insert_to_file("Promocion_Atraccion", promocion_atraccion_data, "generated_data.sql")
    write_insert_to_file("Linea_Factura", linea_factura_data, "generated_data.sql")
    write_insert_to_file("HistorialCategoria", historial_categoria_data, "generated_data.sql")
    write_insert_to_file("cat_promo", cat_promo_data, "generated_data.sql")



generate_sql_for_tables()