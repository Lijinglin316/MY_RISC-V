vsrc 中包含可用于modelsim仿真的所有v文件。
  仿真时需要在cpu.v中注释掉fpga实现需要的两个MEM_cpu，并且取消MEM的注释。
  在define.v中通过宏定义选择正确的MEM实现方式。
  为了fpga实现，需要将cpu.v中的MEM注释，并且取消MEM_cpu的注释，MEM_cpu使用vivado存储生成器调用的bram实现。
vivado.srcs/vivado.sim/vivado.ip_user_files分别包含fpga实现需要的v文件/仿真和fpga实现需要的存储初始化文件/bram ip生成得到的veo与vho文件。
