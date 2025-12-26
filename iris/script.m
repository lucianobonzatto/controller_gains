data = readmatrix('data_x.csv');
X_vel_uav = data(:, 2);
X_cmd_vel = data(:, 3);

data = readmatrix('data_y.csv');
Y_vel_uav = data(:, 2);
Y_cmd_vel = data(:, 3);

data = readmatrix('data_z.csv');
Z_vel_uav = data(:, 2);
Z_cmd_vel = data(:, 3);

data = readmatrix('data_r.csv');
R_vel_uav = data(:, 2);
R_cmd_vel = data(:, 3);

systemIdentification DATA.sid
