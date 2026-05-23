import sys
import requests
import platform
import os
import time
import concurrent.futures

redeemed_or_exhausted_codes = set()

def clear_screen():
    os.system('cls' if platform.system() == "Windows" else 'clear')


def banner():
    clear_screen()
    print("=" * 50)
    print(" TOOL CANH CODE XWORLD ")
    print("=" * 50)


def theo_doi_code(code):
    headers = {
        'accept': '*/*',
        'content-type': 'application/json',
        'origin': 'https://xworld-app.com',
        'referer': 'https://xworld-app.com/',
        'user-agent': 'Mozilla/5.0',
    }

    json_data = {
        'code': code,
        'os_ver': 'android',
        'platform': 'h5',
        'appname': 'app',
    }

    try:
        response = requests.post(
            'https://web3task.3games.io/v1/task/redcode/detail',
            headers=headers,
            json=json_data,
            timeout=10
        ).json()

        if response.get('code') == 0:
            tong = response['data']['user_cnt']
            da_nhap = response['data']['progress']

            return tong - da_nhap

        return None

    except:
        return None


def nhap_code(userId, secretKey, code):
    headers = {
        'accept': '*/*',
        'content-type': 'application/json',
        'origin': 'https://xworld.info',
        'referer': 'https://xworld.info/',
        'user-agent': 'Mozilla/5.0',
        'user-id': userId,
        'user-secret-key': secretKey,
    }

    json_data = {
        'code': code,
        'os_ver': 'android',
        'platform': 'h5',
        'appname': 'app',
    }

    try:
        response = requests.post(
            'https://web3task.3games.io/v1/task/redcode/exchange',
            headers=headers,
            json=json_data,
            timeout=10
        ).json()

        if response.get('code') == 0:
            value = response["data"]["value"]
            currency = response["data"]["currency"]

            print(f"[{userId}] Thành công | +{value} {currency}")

            return True

        else:
            print(f"[{userId}] Thất bại")

            return False

    except:
        print(f"[{userId}] Lỗi mạng")

        return False


def load_data():
    user_ids = []
    user_secretkeys = []

    try:
        if os.path.exists('data_xw_confirm_code.txt'):

            use_old = input(
                "Dùng tài khoản đã lưu? (y/n): "
            ).lower()

            if use_old == 'y':

                with open(
                    'data_xw_confirm_code.txt',
                    'r',
                    encoding='utf-8'
                ) as f:

                    lines = f.readlines()

                for line in lines:

                    line = line.strip()

                    if "|" in line:

                        uid, skey = line.split("|")

                        user_ids.append(uid)
                        user_secretkeys.append(skey)

                if len(user_ids) > 0:
                    return user_ids, user_secretkeys

        amount = int(input("Số lượng tài khoản: "))

        for i in range(amount):

            print(f"\nNhập link tài khoản {i+1}")

            link = input("Link: ").strip()

            try:
                user_id = link.split('?userId=')[1].split('&')[0]
                secret_key = link.split('secretKey=')[1].split('&')[0]

                user_ids.append(user_id)
                user_secretkeys.append(secret_key)

                print("Lấy dữ liệu thành công")

            except:
                print("Link sai định dạng")
                return [], []

        with open(
            'data_xw_confirm_code.txt',
            'w',
            encoding='utf-8'
        ) as f:

            for i in range(len(user_ids)):
                f.write(
                    f"{user_ids[i]}|{user_secretkeys[i]}\n"
                )

        return user_ids, user_secretkeys

    except:
        return [], []


def main():
    banner()

    user_ids, user_secretkeys = load_data()

    if len(user_ids) == 0:
        print("Không có tài khoản")
        return

    banner()

    try:
        threshold = int(
            input("Nhập số lượt còn lại để auto nhập: ")
        )

    except:
        print("Sai định dạng")
        return

    tong_nhan_duoc = {}

    for uid in user_ids:
        tong_nhan_duoc[uid] = 0

    while True:

        code = input(
            "\nNhập code cần canh (Enter để thoát): "
        ).strip()

        if code == "":
            break

        print(f"\nĐang canh code: {code}")

        while True:

            current_time = time.strftime("%H:%M:%S")

            remaining = theo_doi_code(code)

            if remaining is not None:

                print(
                    f"[{current_time}] "
                    f"Còn {remaining} lượt"
                )

                if remaining <= threshold:

                    print(
                        f"[{current_time}] "
                        f"Bắt đầu nhập code..."
                    )

                    success_users = []

                    with concurrent.futures.ThreadPoolExecutor(
                        max_workers=len(user_ids)
                    ) as executor:

                        future_map = {}

                        for i in range(len(user_ids)):

                            future = executor.submit(
                                nhap_code,
                                user_ids[i],
                                user_secretkeys[i],
                                code
                            )

                            future_map[future] = user_ids[i]

                        for future in concurrent.futures.as_completed(future_map):

                            uid = future_map[future]

                            try:
                                result = future.result()

                                if result:
                                    tong_nhan_duoc[uid] += 1
                                    success_users.append(uid)

                            except:
                                pass

                    print("\n" + "=" * 50)
                    print(" THỐNG KÊ ")
                    print("=" * 50)

                    for uid in user_ids:

                        print(
                            f"{uid} | "
                            f"Tổng đã nhận: "
                            f"{tong_nhan_duoc[uid]}"
                        )

                    print("=" * 50)

                    print("\nCanh code tiếp theo...\n")

                    break

            else:
                print(
                    f"[{current_time}] "
                    f"Không lấy được dữ liệu"
                )

            time.sleep(1)


if __name__ == "__main__":
    main()
