import requests
import sys
import logging

# Known private trackers
PRIVATE_TRACKERS = [
    "https://tracker.torrentleech.org",
    "http://tracker.hebits.net",
    "https://tracker.tleechreload.org",
]

PUBLIC_SEED_RATIO_LIMIT = 0.2

def is_tracker_private(tracker_url):
    return any(tracker_url.startswith(private_tracker) for private_tracker in PRIVATE_TRACKERS)

def get_torrents(transmission_host):
    url = f"http://{transmission_host}/transmission/rpc"

    response = requests.get(url)
    if response.status_code == 409:  # Session ID required
        session_id = response.headers['X-Transmission-Session-Id']
        headers = {"X-Transmission-Session-Id": session_id}
        # Make the actual request to get torrents
        response = requests.post(
            url,
            headers=headers,
            json={"method": "torrent-get", "arguments": {"fields": ["id", "name", "trackers"]}}
        )
        if response.status_code != 200:
            logging.error(f"Failed to fetch torrents: {response.text}")
            sys.exit(1)
    elif response.status_code == 200:
        session_id = response.headers['X-Transmission-Session-Id']
        # Make the actual request to get torrents
        response = requests.post(
            url,
            headers={"X-Transmission-Session-Id": session_id},
            json={"method": "torrent-get", "arguments": {"fields": ["id", "name", "trackers"]}}
        )
    else:
        logging.error(f"Unexpected status code: {response.status_code}")
        sys.exit(1)

    return response.json()["arguments"]["torrents"], session_id

def set_seeding_limit(transmission_host, session_id, torrent_id, seed_ratio_limit):
    url = f"http://{transmission_host}/transmission/rpc"
    headers = {"X-Transmission-Session-Id": session_id}
    payload = {
        "method": "torrent-set",
        "arguments": {
            "ids": [torrent_id],
            "seedRatioLimit": seed_ratio_limit,
            "seedRatioMode": 1
        }
    }

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        logging.info(f"Set seeding limit for Torrent ID {torrent_id} to {seed_ratio_limit}")
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to set seeding limit for Torrent ID {torrent_id}: {e}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 script.py <TRANSMISSION_HOST>")
        sys.exit(1)

    transmission_host = sys.argv[1]

    try:
        torrents, session_id = get_torrents(transmission_host)
        for torrent in torrents:
            torrent_id = torrent["id"]
            torrent_name = torrent["name"]

            is_private = any(is_tracker_private(tracker["announce"]) for tracker in torrent["trackers"])

            if not is_private:
                logging.info(f"  Setting seeding limit for Public Torrent: {torrent_name}")
                set_seeding_limit(transmission_host, session_id, torrent_id, PUBLIC_SEED_RATIO_LIMIT)
            else:
                logging.info(f"  Skipping Private Torrent: {torrent_name}")
    except Exception as e:
        logging.error(f"Error: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()

