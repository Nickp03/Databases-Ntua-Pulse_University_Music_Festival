import pymysql
import csv
import pandas as pd

# Function to connect to the database
def connect():
    df = pd.read_csv('Credentials.csv', header=None)
    host,user,password,db = df[0].tolist()
    conn = pymysql.connect(host=host, user=user, password=password, database=db,
                           cursorclass=pymysql.cursors.DictCursor)
    with conn.cursor() as cur:
        cur.execute("SELECT DATABASE()")
        print("Connected to:", cur.fetchone())
    return conn


# Generic helper to fill tables from CSV
def _fill_from_csv(table, columns, csv_path):
    placeholders = ", ".join(["%s"] * len(columns))
    cols         = ", ".join(columns)
    sql          = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn         = connect()
    try:
        cur = conn.cursor()
        with open(csv_path, newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader)  # skip header
            for row in reader:
                if len(row) != len(columns):
                    continue
                # Convert '' → None so MySQL sees NULL, not an invalid integer
                clean = [None if cell == '' else cell for cell in row]
                cur.execute(sql, clean)
        conn.commit()   # commit *before* closing
    except Exception as e:
        print(f"Error populating {table}:", e)
    finally:
        cur.close()
        conn.close()
        print(f"Finished {table}")

# Helper to fill seller_queue from CSV
def _fill_from_csv(table, columns, csv_path):
    placeholders = ", ".join(["%s"] * len(columns))
    cols         = ", ".join(columns)
    sql          = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn         = connect()
    try:
        cur = conn.cursor()
        # Άνοιγμα και ανάγνωση του CSV
        with open('seller_queue.csv', mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                owner_id=row['Owner_id']
                ticket_id=row['Ticket_id']
            # Κλήση stored procedure για κάθε γραμμή
            cur.callproc('insert_into_seller_queue', (int(owner_id),int(ticket_id)))
        conn.commit()   # commit *before* closing
    except Exception as e:
        print(f"Error populating {table}:", e)
    finally:
        cur.close()
        conn.close()
        print(f"Finished {table}")




# Fill functions for each table
def fill_location(): _fill_from_csv('location',
    ['address','latitude','longitude','city','country','continent'],
    'location.csv')

def fill_festival(): _fill_from_csv('festival',
    ['year','start_date','end_date','location_id'],
    'festival.csv')

def fill_stage(): _fill_from_csv('stage',
    ['name','description','max_capacity','equipment'],
    'stage.csv')

def fill_event(): _fill_from_csv('event',
    ['festival_id','stage_id','event_date','start_time','end_time'],
    'event.csv')

def fill_staff_role(): _fill_from_csv('staff_role',
    ['role_name'],
    'staff_role.csv')

def fill_experience_level(): _fill_from_csv('experience_level',
    ['level_name'],
    'experience_level.csv')

def fill_staff(): _fill_from_csv('staff',
    ['name','age','role_id','level_id'],
    'staff.csv')

def fill_stage_staff(): _fill_from_csv('stage_staff',
    ['stage_id','event_id','staff_id'],
    'stage_staff.csv')

def fill_genre(): _fill_from_csv('genre',
    ['genre_name'],
    'genre.csv')

def fill_subgenre(): _fill_from_csv('subgenre',
    ['subgenre_name','genre_id'],
    'subgenre.csv')

def fill_artist(): _fill_from_csv('artist',
    ['artist_name','artist_lastname','stage_name','DOB','genre_id','subgenre_id','website','instagram'],
    'artist.csv')

def fill_band(): _fill_from_csv('band',
    ['band_name','date_of_creation','website','instagram','genre_id','subgenre_id'],
    'band.csv')

def fill_artist_band(): _fill_from_csv('artist_band',
    ['artist_id','band_id'],
    'artist_band.csv')

def fill_perf_kind(): _fill_from_csv('perf_kind',
    ['kind_name'],
    'perf_kind.csv')

def fill_perf_type(): _fill_from_csv('perf_type',
    ['type_name'],
    'perf_type.csv')

def fill_performance(): _fill_from_csv('performance',
    ['perf_datetime','duration','kind_id','type_id','artist_id','band_id','event_id'],
    'performance.csv')

def fill_payment_method(): _fill_from_csv('payment_method',
    ['pm_name'],
    'payment_method.csv')

def fill_owner(): _fill_from_csv('owner',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','total_charge'],
    'owner.csv')

def fill_ticket_category(): _fill_from_csv('ticket_category',
    ['cat_name'],
    'ticket_category.csv')

def fill_ticket(): _fill_from_csv('ticket',
    ['ticket_category','purchase_date','cost','method_of_purchase','activated','event_id','owner_id'],
    'ticket.csv')

def fill_buyer(): _fill_from_csv('buyer',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','number_of_desired_tickets'],
    'buyer.csv')

def fill_seller_queue(): _fill_from_csv('seller_queue',
    ['seller_id','interest_datetime','ticket_id','event_id','ticket_category','sold'],
    'seller_queue.csv')

def fill_buyer_queue(): _fill_from_csv('buyer_queue',
    ['buyer_id','interest_datetime','ticket_id','event_id','ticket_category','sold'],
    'buyer_queue.csv')

def fill_review(): _fill_from_csv('review',
    ['ticket_id','interpretation','sound_and_lighting','stage_presence','organization','overall_impression','review_date','performance_id'],
    'review.csv')

if __name__ == "__main__":
    fill_location()
    fill_festival()
    fill_stage()
    fill_event()
    fill_staff_role()
    fill_experience_level()
    fill_staff()
    fill_stage_staff()
    fill_genre()
    fill_subgenre()
    fill_artist()
    fill_band()
    fill_artist_band()
    fill_perf_kind()
    fill_perf_type()
    fill_performance()
    fill_payment_method()
    fill_owner()
    fill_ticket_category()
    fill_ticket()
    fill_buyer()
    fill_seller_queue()
    fill_buyer_queue()
    fill_review()
    print("All tables populated.")