#!/usr/bin/env python3
# Plot only dots for each received position (no connecting line)
# Usage:
#   python3 xy_traj_plotter_pg.py --topic /abv/state --pkg robot_idl --msg AbvState --csv traj.csv

import argparse, csv, sys, importlib
from collections import deque
from threading import Thread, Event
import rclpy
from rclpy.node import Node
from rclpy.qos import QoSProfile, ReliabilityPolicy, HistoryPolicy
from PyQt5 import QtWidgets, QtCore
import pyqtgraph as pg


def import_ros_msg(pkg: str, msg: str):
    mod_name = f"{pkg}.msg"
    mod = importlib.import_module(mod_name)
    return getattr(mod, msg)


class XYNode(Node):
    def __init__(self, topic, MsgType, max_points):
        super().__init__('xy_traj_plotter_pg')
        qos = QoSProfile(
            reliability=ReliabilityPolicy.BEST_EFFORT,
            history=HistoryPolicy.KEEP_LAST,
            depth=100
        )
        self.sub = self.create_subscription(MsgType, topic, self.cb, qos)
        self.xs = deque(maxlen=None if max_points <= 0 else max_points)
        self.ys = deque(maxlen=None if max_points <= 0 else max_points)

    def cb(self, msg):
        try:
            x = float(msg.position.x)
            y = float(msg.position.y)
        except Exception:
            self.get_logger().error("Message missing position.x/position.y")
            return
        self.xs.append(x)
        self.ys.append(y)


class XYPlotApp(QtWidgets.QMainWindow):
    def __init__(self, node, csv_path):
        super().__init__()
        self.node = node
        self.csv_path = csv_path
        self.setWindowTitle("XY Points (x vs y)")
        self.resize(800, 600)

        cw = QtWidgets.QWidget()
        self.setCentralWidget(cw)
        layout = QtWidgets.QVBoxLayout(cw)

        self.plot = pg.PlotWidget()
        self.plot.showGrid(x=True, y=True, alpha=0.3)
        self.plot.setLabel('bottom', 'x')
        self.plot.setLabel('left', 'y')
        self.plot.setAspectLocked(lock=True)
        self.plot.setXRange(-5, 5, padding=0.0)
        self.plot.setYRange(-5, 5, padding=0.0)
        self.plot.setLimits(xMin=-5, xMax=5, yMin=-5, yMax=5)
        layout.addWidget(self.plot)

        # Example static obstacle at (x=1.0, y=-1.0) with radius 0.25
        #x_obs, y_obs, r_obs = 1.0, 1.0, 0.25

        def add_obs(x_obs, y_obs, r_obs): 
            
            # pyqtgraph uses scene coordinates; center the circle by shifting its rect
            obstacle = QtWidgets.QGraphicsEllipseItem(
            x_obs - r_obs,   # left
            y_obs - r_obs,   # top
            2 * r_obs,       # width
            2 * r_obs        # height
             )
            obstacle.setBrush(pg.mkBrush(255, 0, 0, 100))  # semi-transparent red
            obstacle.setPen(pg.mkPen(200, 0, 0, width=1.5))
            self.plot.addItem(obstacle)
        
        add_obs(1, 1, 0.25)
        add_obs(0, 1.75, 0.25)
    
        # Scatter plot only (no connecting line)
        self.scatter = pg.ScatterPlotItem(size=6, pen=None, brush=pg.mkBrush(0, 170, 255, 180))
        self.plot.addItem(self.scatter)

        # refresh timer
        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.update_plot)
        self.timer.start(30)

    def update_plot(self):
        xs = list(self.node.xs)
        ys = list(self.node.ys)
        if not xs:
            return
        self.scatter.setData(xs, ys)  # show all points accumulated

    def closeEvent(self, ev):
        if self.csv_path:
            with open(self.csv_path, 'w', newline='') as f:
                w = csv.writer(f)
                w.writerow(['x', 'y'])
                for x, y in zip(self.node.xs, self.node.ys):
                    w.writerow([x, y])
            print(f"Saved CSV: {self.csv_path}")
        super().closeEvent(ev)


def main():
    ap = argparse.ArgumentParser(description="XY scatter plot (pyqtgraph) from custom ROS 2 message")
    ap.add_argument('--topic', default='/abv/state')
    ap.add_argument('--pkg', required=True)
    ap.add_argument('--msg', required=True)
    ap.add_argument('--max-points', type=int, default=0)
    ap.add_argument('--csv', default='')
    args = ap.parse_args()

    MsgType = import_ros_msg(args.pkg, args.msg)

    rclpy.init()
    node = XYNode(args.topic, MsgType, args.max_points)

    stop_evt = Event()
    def spinner():
        while rclpy.ok() and not stop_evt.is_set():
            rclpy.spin_once(node, timeout_sec=0.01)
    th = Thread(target=spinner, daemon=True)
    th.start()

    app = QtWidgets.QApplication(sys.argv)
    win = XYPlotApp(node, args.csv if args.csv else None)
    win.show()
    try:
        app.exec_()
    finally:
        stop_evt.set()
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()

