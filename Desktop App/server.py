from flask import Flask 
from flask_sockets import Sockets

import pygame , sys

from pygame.locals import *
import math
from random import randint
import time
import striker


app = Flask(__name__) 
sockets = Sockets(app)


@sockets.route('/accelerometer')
def echo_socket(ws):
	global now

	while True:
		message = ws.receive()
		# print(message)


		player , data = message.split(":")
		player=int(player)
		y_data,x_data=map(int,data.split(','))
		# print(player,x_data,y_data)

		# print(y_data)
		if y_data<0:
			y_data = 0
		if y_data >90:
			y_data = 90

		y_data = y_data/9

		if striker.y_control == 2:

			if player == 1:
				striker.striker1.update_pos_y(y_data , player)
			else:
				striker.striker2.update_pos_y(y_data , player)



		if  x_data>=0:
			if x_data>45:
				x_data = 45
			x_rat = x_data/45
			if player == 1:
				striker.striker1.update_pos_x(-1* x_rat)
			else:
				striker.striker2.update_pos_x(-1* x_rat)
		else:
			if x_data<-45:
				x_data=-45
			x_rat = abs(x_data/45)
			if player == 1:
				striker.striker1.update_pos_x( x_rat)
			else:
				striker.striker2.update_pos_x( x_rat)





@sockets.route('/slider')
def echo_socket(ws):

	# while True:
	while striker.y_control == 1:
		message = ws.receive()
		# print(message)

		player , slide = message.split(":")
		if  not (slide=='Stop' or slide=='Start'):
			player = int(player)
			slide = float(slide)

			if player == 1:
				striker.striker1.update_pos_y(slide , player)
			else:
				striker.striker2.update_pos_y(slide , player)



@sockets.route('/button')
def echo_socket(ws):

	while True:
		message = ws.receive()
		# print(message)

		player , disappear = map(int,message.split(":"))

		if player == 1:
			striker.striker1.disappear_striker = True
		else:
			striker.striker2.disappear_striker = True





	

@app.route('/') 
def hello(): 
	return 'Hello World!'

def start(pygame1,DISPLAYSURF1):
	global pygame
	global DISPLAYSURF
	pygame,DISPLAYSURF = pygame1,DISPLAYSURF1


	# print(id(car))

	print("server started")
	global now
	now = time.time()
	from gevent import pywsgi
	from geventwebsocket.handler import WebSocketHandler
	server = pywsgi.WSGIServer(('0.0.0.0', 7310), app, handler_class=WebSocketHandler)

	server.serve_forever()
