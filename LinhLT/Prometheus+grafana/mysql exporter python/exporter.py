# Set the python path
import MySQLdb as mdb
import inspect
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))))

import threading
from http.server import HTTPServer
import socket
import time

from prometheus.collectors import Gauge
from prometheus.registry import Registry
from prometheus.exporter import PrometheusMetricHandler
import psutil

PORT_NUMBER = 4444
host="127.0.0.1"
port=3305
user="root"
password="Welcome123"

def gather_data(registry):
    """Gathers the metrics"""

    # Get the host name of the machine
    host = socket.gethostname()

    # Create our collectors
    mysql_metric = Gauge("MySQL_slave", "MySQL slave",
                       {'host': host})
    #cpu_metric = Gauge("cpu_usage_percent", "CPU usage percent.",
                       #{'host': host})

    # register the metric collectors
    registry.register(mysql_metric)
    #registry.register(cpu_metric)

    # Start gathering metrics every second
    while True:
        time.sleep(1)

        # Add ram metrics
        #ram = psutil.virtual_memory()
        #swap = psutil.swap_memory()

        #ram_metric.set({'type': "virtual", }, ram.used)
        #ram_metric.set({'type': "virtual", 'status': "cached"}, ram.cached)
        #ram_metric.set({'type': "swap"}, swap.used)

        # Add cpu metrics
        #for c, p in enumerate(psutil.cpu_percent(interval=1, percpu=True)):
            #cpu_metric.set({'core': c}, p)
        con = mdb.connect(host=host, port=port, user=user, passwd=password);
        cur = con.cursor(mdb.cursors.DictCursor)
        cur.execute('show slave status')
        slave_status = cur.fetchone()
        slave_file = slave_status["Seconds_Behind_Master"]
        slave_sql_running = "1" if slave_status["Slave_SQL_Running"] == "Yes" else "0"
        slave_io_running = "1" if slave_status["Slave_IO_Running"] == "Yes" else "0"
        con.close()
        #mysql_metric.set({},10)
        mysql_metric.set({'type': "Seconds_Behind_Master"},str(slave_file))
        mysql_metric.set({'type': "Slave_SQL_Running"},slave_sql_running)
        mysql_metric.set({'type': "Slave_IO_Running"},slave_io_running)

if __name__ == "__main__":

    # Create the registry
    registry = Registry()

    # Create the thread that gathers the data while we serve it
    thread = threading.Thread(target=gather_data, args=(registry, ))
    thread.start()

    # Set a server to export (expose to prometheus) the data (in a thread)
    try:
        # We make this to set the registry in the handler
        def handler(*args, **kwargs):
            PrometheusMetricHandler(registry, *args, **kwargs)

        server = HTTPServer(('', PORT_NUMBER), handler)
        server.serve_forever()

    except KeyboardInterrupt:
        server.socket.close()
        thread.join()