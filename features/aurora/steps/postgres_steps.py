import os
import psycopg2
from behave import given, when, then

CC_TABLES = ["claims_partd", "ndc", "pharmacies", "providers", "beneficiaries"]


@given('I am connected to Aurora')
def step_connect(context):
    context.conn = psycopg2.connect(
        host=os.environ["DB_HOST"], port=int(os.environ["DB_PORT"]),
        database=os.environ["DB_NAME"], user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"])
    context.cursor = context.conn.cursor()


@when('I query the databasechangelog table')
def step_query_changelog(context):
    context.cursor.execute("SELECT COUNT(*) FROM cc_system.databasechangelog")
    context.count = context.cursor.fetchone()[0]


@then('it should contain migration records')
def step_verify_migrations(context):
    assert context.count > 0, f"Expected migration records, found {context.count}"


@when('I count tables in cc_system schema')
def step_count_tables(context):
    context.cursor.execute("SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'cc_system'")
    context.table_count = context.cursor.fetchone()[0]


@then('I should see at least {min_count:d} tables')
def step_verify_table_count(context, min_count):
    assert context.table_count >= min_count, f"Expected >= {min_count}, found {context.table_count}"


@when('I count rows in cc_system tables')
def step_count_rows(context):
    context.cc_counts = {}
    for table in CC_TABLES:
        context.cursor.execute(f"SELECT COUNT(*) FROM cc_system.{table}")
        context.cc_counts[table] = context.cursor.fetchone()[0]
        print(f"  {table}: {context.cc_counts[table]}")


@then('each table should have records')
def step_verify_data(context):
    for table, count in context.cc_counts.items():
        assert count > 0, f"Table {table} is empty"
    context.cursor.close()
    context.conn.close()
