# Nombre del archivo fuente principal (sin extensión)
SRC ?= archivo

# Directorios
SRC_DIR = daclib
BUILD_DIR = build

# Archivos fuente
#DACLIB_SRC = $(SRC_DIR)/daclib.c
DACLIB_SRC = $(SRC_DIR)/daclib.s
START_SRC = $(SRC_DIR)/start.s
LD_SCRIPT = $(SRC_DIR)/baremetal.ld

# Archivos objeto generados en build/
DACLIB_OBJ = $(BUILD_DIR)/daclib.o
START_OBJ = $(BUILD_DIR)/start.o
SRC_OBJ = $(BUILD_DIR)/$(SRC).o
ELF = $(BUILD_DIR)/riscv.elf

# Compiladores y opciones
CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
CFLAGS = -c -g -O0 -ffreestanding -march=rv32i -mabi=ilp32
ASFLAGS = -g -march=rv32i -mabi=ilp32
LDFLAGS = -T $(LD_SCRIPT) -m elf32lriscv

# Regla por defecto
default: $(ELF)

# Crear la carpeta build si no existe
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compilar los archivos en build/
$(DACLIB_OBJ): $(DACLIB_SRC) | $(BUILD_DIR)
#	$(CC) $(CFLAGS) -o $@ $<
	$(AS) $(ASFLAGS) -o $@ $<

$(START_OBJ): $(START_SRC) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(SRC_OBJ): $(SRC).s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

# Enlazar
$(ELF): $(DACLIB_OBJ) $(START_OBJ) $(SRC_OBJ) $(LD_SCRIPT)
	$(LD) $(LDFLAGS) -o $@ $(DACLIB_OBJ) $(START_OBJ) $(SRC_OBJ)

#$(ELF): $(START_OBJ) $(SRC_OBJ) $(LD_SCRIPT)
#	$(LD) $(LDFLAGS) -o $@ $(START_OBJ) $(SRC_OBJ)

# Ejecutar con QEMU
run: $(ELF)
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios $(ELF)

debug: $(ELF)
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -s -S -bios $(ELF)

# Limpiar
clean:
	rm -rf $(BUILD_DIR)
