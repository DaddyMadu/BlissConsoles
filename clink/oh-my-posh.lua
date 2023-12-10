load(io.popen('oh-my-posh init cmd --config '
 .. os.getenv("localappdata")
 .. '\\Programs\\oh-my-posh\\themes\\kushal.omp.json'):read("*a"))()
