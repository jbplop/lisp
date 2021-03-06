(ql:quickload :lispbuilder-sdl)

(defvar lifearray (make-array '(100 100)))
(defvar pause 1)
(defvar rate 5)
(defvar size 25)
(defvar sizex 0)
(defvar sizey 0)
(defvar width 0)
(defvar height 0)
(defvar indexx 0)
(defvar indexy 0)

(defun init-array (lifearray)
	(loop for i from 0 to (1- (array-dimension lifearray 0)) do
  		(loop for j from 0 to (1- (array-dimension lifearray 1)) do
			(setf (aref lifearray i j)  0))))

(defun count-neighborhood (i j lifearray)
	(let ((next-i (1+ i))
		  (prev-i (1- i))
		  (next-j (1+ j))
		  (prev-j (1- j)))
	(+ (if (array-in-bounds-p lifearray prev-i prev-j)
		 (aref lifearray prev-i prev-j)
		 0)
	   (if (array-in-bounds-p lifearray prev-i j)
		 (aref lifearray prev-i j)
		 0)
	   (if (array-in-bounds-p lifearray prev-i next-j)
	   (aref lifearray prev-i next-j)
		 0)
	   (if (array-in-bounds-p lifearray i prev-j) 
	   (aref lifearray i prev-j)
		 0)
	   (if (array-in-bounds-p lifearray i next-j)
	   (aref lifearray i next-j)
		 0)
	   (if (array-in-bounds-p lifearray next-i prev-j)
	   (aref lifearray next-i prev-j)
		 0)
	   (if (array-in-bounds-p lifearray next-i j)
	   (aref lifearray next-i j)
		 0)
	   (if (array-in-bounds-p lifearray next-i next-j)
	   (aref lifearray next-i next-j)
		 0))))

(defun next-life (lifearray)
	(let ((next-lifearray (alexandria:copy-array lifearray)))
		(loop for i from 0 to (1- (array-dimension lifearray 0)) do
			(loop for j from 0 to (1- (array-dimension lifearray 1)) do
				(cond ((and (zerop (aref lifearray i j)) ; birth
					   (= (count-neighborhood i j lifearray) 3))
					   (setf (aref next-lifearray i j) 1))
					 ((and (= (aref lifearray i j) 1)   ; die
					 (or (<= (count-neighborhood i j lifearray) 1)
					(>= (count-neighborhood i j lifearray) 4)))
					(setf (aref next-lifearray i j) 0)))))
		      next-lifearray))

(defun main-loop()
	(when (sdl:mouse-left-p)
	(if (array-in-bounds-p lifearray (+ (floor ( / (sdl:mouse-x) size)) indexx) (+ (floor ( / (sdl:mouse-y))) indexy ))
	(if (= (aref lifearray (+ (floor ( / (sdl:mouse-x) size)) indexx) (+ (floor ( / (sdl:mouse-y) size)) indexy )) 1)
			(setf (aref lifearray (+ (floor ( / (sdl:mouse-x) size)) indexx) (+ (floor ( / (sdl:mouse-y) size)) indexy )) 0)
			(setf (aref lifearray (+ (floor ( / (sdl:mouse-x) size)) indexx) (+ (floor ( / (sdl:mouse-y) size)) indexy )) 1))))
;	  (print (floor ( / (sdl:mouse-x) 5.0))))
	(when (sdl:mouse-wheel-down-p)
	  (print "dw"))
	(when (sdl:mouse-wheel-up-p)
	  (print "up"))

)

(defun test()
	(sdl:with-init ()
		(sdl:window 500 500
			:double-buffer t
			:title-caption "Tutorial 1"
			:icon-caption "Tutorial 1")
		(init-array lifearray)
		(setf (sdl:frame-rate) 15)
		(sdl:with-events ()
			(:key-down-event (:key key)
				(when (sdl:key= key :sdl-key-escape)
					(sdl:push-quit-event))
				(when (sdl:key= key :sdl-key-p)
					(if (= pause 0)
					  (setf (sdl::frame-rate) 15)
					  (setf (sdl::frame-rate) rate))
					(if (= pause 0)
						(setq pause 1)
						(setq pause 0)))
				(when (sdl:key= key :sdl-key-period)
					(if (< (sdl:frame-rate) 60)
						(incf rate))
					(if (< (sdl:frame-rate) 60)
						(incf (sdl:frame-rate) 2)))
				(when (sdl:key= key :sdl-key-comma)
					(if (> (sdl:frame-rate) 1)
						(decf rate))
					(if (> (sdl:frame-rate) 1)
						(decf (sdl:frame-rate) 2)))
				(when (sdl:key= key :sdl-key-r)
					(init-array lifearray)
					(setq size 25)
					(setq indexx 0)
					(setq indexy 0)
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-kp-plus)
					(if (< size 40)
						(incf size 2))
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-kp-minus)
					(if (> size 6)
						(decf size 2))
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-w)
					(incf indexy)
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-a)
					(incf indexx)
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-s)
					(decf indexy)
					(sdl:clear-display sdl:*black*))
				(when (sdl:key= key :sdl-key-d)
					(decf indexx)
					(sdl:clear-display sdl:*black*))


				;(format t "~C" #\linefeed)
				)
			(:quit-event () t)
			(:idle ()
				(main-loop)
				(if (= pause 0)
				(setf lifearray (next-life lifearray)))
					(loop for i from 0 to (1- (array-dimension lifearray 0)) do
						(loop for j from 0 to (1- (array-dimension lifearray 1)) do
							(if (if (array-in-bounds-p lifearray (+ i indexx) (+ j indexy))
							  	(= (aref lifearray (+ i indexx) (+ j indexy)) 0))
		    					(sdl:draw-box (sdl:rectangle :x (* i size) :y (* j size) :w (- size 1) :h (- size 1))
									:color sdl:*green*)
			 		  			(sdl:draw-box (sdl:rectangle :x (* i size) :y (* j size) :w (- size 1) :h (- size 1))
									:color sdl:*red*))))
				(sdl:update-display))
				(exit))
))

(defun print_usage()
	(print "usage: sbcl --load game_of_life.lsp [-h] width height
		   
		   positional arguments:
		   width width of the grid
		   height height of the grid
		   
		   optional arguments:
		   -h, --help show this help message and exit"))


(defun create_cells_data(width height)
	(if (< width sizex)
  		(setf sizex width))
	(if (< height sizey)
		(setf sizey height))
	
	(test))	

(defun test_value(width height)
  	(if (and (> width 2) (> height 2))
	  		(create_cells_data width height)
					(print_usage)))

(defun test_num(width height)
  	(setq width (parse-integer width :junk-allowed t))
		(setq height (parse-integer height :junk-allowed t))
			(if (and (numberp width) (numberp height))
			  		(test_value width height)
							(print_usage)))

(sb-int:with-float-traps-masked (:invalid :inexact :overflow)
	(if (/= (length *posix-argv*) 3)
		(print_usage)
		(test_num (elt *posix-argv* 1) (elt *posix-argv* 2)))
(exit))
