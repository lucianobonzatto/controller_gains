import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os

dir_path = os.path.dirname(os.path.realpath(__file__))

def ler_csv(nome_arquivo):
    try:
        file_path = os.path.join(dir_path, nome_arquivo)
        df = pd.read_csv(file_path)
        return df
    except FileNotFoundError:
        print("Arquivo não encontrado.")
        return None

uav_r = ler_csv("uav_r.csv")
uav_x = ler_csv("uav_x.csv")
uav_y = ler_csv("uav_y.csv")
uav_z = ler_csv("uav_z.csv")

uav_r = uav_r.drop_duplicates(subset=uav_r.columns.difference(['Time', "X_cmd_vel", "Y_cmd_vel", "Z_cmd_vel", "yaw_cmd_vel"]))
uav_x = uav_x.drop_duplicates(subset=uav_x.columns.difference(['Time', "X_cmd_vel", "Y_cmd_vel", "Z_cmd_vel", "yaw_cmd_vel"]))
uav_y = uav_y.drop_duplicates(subset=uav_y.columns.difference(['Time', "X_cmd_vel", "Y_cmd_vel", "Z_cmd_vel", "yaw_cmd_vel"]))
uav_z = uav_z.drop_duplicates(subset=uav_z.columns.difference(['Time', "X_cmd_vel", "Y_cmd_vel", "Z_cmd_vel", "yaw_cmd_vel"]))

uav_r.to_csv("uav_r_new.csv", index=False)
uav_x.to_csv("uav_x_new.csv", index=False)
uav_y.to_csv("uav_y_new.csv", index=False)
uav_z.to_csv("uav_z_new.csv", index=False)

print("uav_r:", uav_r["Time"].diff().dropna().mean())
print("uav_x:", uav_x["Time"].diff().dropna().mean())
print("uav_y:", uav_y["Time"].diff().dropna().mean())
print("uav_z:", uav_z["Time"].diff().dropna().mean())


# # Plotting the data
# plt.figure(figsize=(12, 8))

# # Specify the columns to plot
# # columns_to_plot = ["X_vel_uav", "Y_vel_uav", "Z_vel_uav", "yaw_vel_uav", "X_cmd_vel", "Y_cmd_vel", "Z_cmd_vel", "yaw_cmd_vel"]
# # columns_to_plot = ["X_vel_uav", "Y_vel_uav", "Z_vel_uav", "yaw_vel_uav"]
# columns_to_plot = ["X_vel_uav"]

# for col in columns_to_plot:
#     plt.scatter(uav_r["Time"], uav_r[col], label=col, s=10)

# # Customize the plot
# plt.title("UAV Data")
# plt.xlabel("Time")
# plt.ylabel("Value")
# plt.legend()
# plt.grid(True)

# # Show the plot
# plt.show()
