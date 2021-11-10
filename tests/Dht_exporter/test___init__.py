import dht_exporter


def test___init__():
    new_app = dht_exporter(4, "roomName", False)
    assert new_app.room == "roomName"
