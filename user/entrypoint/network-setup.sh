#!/usr/bin/env bash

################################################################################
# Network Static IP Configuration Script - Docker Optimized
# Purpose: Detect DHCP-assigned IP and configure static IP
# Environment: Docker Container on Ubuntu 22.04+
# Design: SOLID principles + Production-ready
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly ROUTER_GATEWAY="${ROUTER_GATEWAY:-10.10.3.1}"
readonly DNS_SERVER="${DNS_SERVER:-10.10.3.200}"
readonly DNS_FALLBACK="10.10.3.200"
readonly NETPLAN_DIR="/etc/netplan"
readonly NETPLAN_CONFIG="${NETPLAN_DIR}/01-static-ip.yaml"
readonly RESOLV_CONFIG="/etc/resolv.conf"
readonly LOG_FILE="/var/log/network-setup.log"
readonly LOCK_FILE="/tmp/network-setup.lock"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# ============================================================================
# LOGGING & OUTPUT
# ============================================================================
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}" 2>/dev/null || true
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $@" >&2
    log "INFO" "$@"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $@" >&2
    log "SUCCESS" "$@"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" >&2
    log "ERROR" "$@"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $@" >&2
    log "WARNING" "$@"
}

# ============================================================================
# ERROR HANDLING & CLEANUP
# ============================================================================
cleanup() {
    rm -f "${LOCK_FILE}" 2>/dev/null || true
}

trap cleanup EXIT
trap 'log_error "Script interrupted"; exit 130' INT TERM

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root o con sudo"
        exit 1
    fi
}

acquire_lock() {
    if [[ -f "${LOCK_FILE}" ]]; then
        local pid=$(cat "${LOCK_FILE}" 2>/dev/null || echo "unknown")
        log_warning "Script ya está en ejecución (PID: ${pid})"
        exit 1
    fi
    echo $$ > "${LOCK_FILE}"
}

# ============================================================================
# NETWORK DETECTION & ANALYSIS
# ============================================================================
get_primary_interface() {
    local interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [[ -z "${interface}" ]]; then
        log_error "No se encontró interfaz de red activa"
        return 1
    fi
    
    echo "${interface}"
}

get_current_ip() {
    local interface="$1"
    local ip=$(ip addr show "${interface}" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -n1)
    echo "${ip}"
}

get_current_gateway() {
    local interface="$1"
    local gateway=$(ip route | grep "default via" | awk '{print $3}' | head -n1)
    echo "${gateway}"
}

get_current_dns() {
    grep -oP '(?<=nameserver\s)\S+' "${RESOLV_CONFIG}" 2>/dev/null | head -n1 || echo ""
}

get_netmask() {
    local interface="$1"
    local netmask=$(ip addr show "${interface}" | grep "inet " | awk '{print $2}' | cut -d'/' -f2)
    echo "${netmask}"
}

validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

is_in_network_range() {
    local ip="$1"
    local network_prefix="$2" # Ej: "10.10.3"
    
    if [[ ${ip} == ${network_prefix}.* ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# CONFIGURATION GENERATION
# ============================================================================
generate_netplan_config() {
    local interface="$1"
    local ip="$2"
    local netmask="$3"
    local gateway="$4"
    local dns="$5"
    
    # Crear directorio si no existe
    mkdir -p "${NETPLAN_DIR}"
    
    # Respaldar configuración anterior si existe
    if [[ -f "${NETPLAN_CONFIG}" ]]; then
        cp "${NETPLAN_CONFIG}" "${NETPLAN_CONFIG}.bak.$(date +%s)"
        log_info "Respaldo anterior guardado"
    fi
    
    # Generar YAML optimizado y validado para Netplan (Ubuntu 22.04+)
    cat > "${NETPLAN_CONFIG}" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${interface}:
      dhcp4: false
      addresses:
        - ${ip}/${netmask}
      routes:
        - to: default
          via: ${gateway}
      nameservers:
        addresses: [${dns}, ${DNS_FALLBACK}]
EOF
    
    chmod 600 "${NETPLAN_CONFIG}"
    log_info "Configuración netplan generada: ${NETPLAN_CONFIG}"
}

configure_resolv_conf() {
    local dns="$1"
    
    # Respaldar resolv.conf original
    if [[ -f "${RESOLV_CONFIG}" ]]; then
        cp "${RESOLV_CONFIG}" "${RESOLV_CONFIG}.bak.$(date +%s)"
    fi
    
    # Crear nuevo resolv.conf
    cat > "${RESOLV_CONFIG}" <<EOF
# Configuración automática por network-setup.sh
nameserver ${dns}
nameserver ${DNS_FALLBACK}
EOF
    
    chmod 644 "${RESOLV_CONFIG}"
    log_info "DNS configurado en ${RESOLV_CONFIG}"
}

# ============================================================================
# DEPLOYMENT & VERIFICATION
# ============================================================================
validate_netplan_config() {
    if command -v netplan &> /dev/null; then
        if netplan validate 2>/dev/null; then
            log_success "Configuración netplan válida"
            return 0
        else
            log_error "Configuración netplan inválida"
            # Debug: mostrar el archivo para inspección
            log_error "Contenido del archivo:"
            cat "${NETPLAN_CONFIG}" >&2 || true
            return 1
        fi
    else
        log_warning "netplan no disponible, omitiendo validación"
        return 0
    fi
}

apply_netplan_config() {
    log_info "Aplicando configuración de netplan..."
    
    if ! validate_netplan_config; then
        log_error "Validación de configuración falló"
        return 1
    fi
    
    if netplan apply 2>/dev/null; then
        log_success "Configuración de netplan aplicada"
        return 0
    else
        log_error "Error al aplicar configuración de netplan"
        return 1
    fi
}

verify_network_configuration() {
    local interface="$1"
    local expected_ip="$2"
    
    log_info "Verificando configuración de red..."
    
    sleep 2 # Esperar a que se apliquen cambios
    
    local current_ip=$(get_current_ip "${interface}")
    
    if [[ "${current_ip}" == "${expected_ip}" ]]; then
        log_success "IP configurada correctamente: ${current_ip}"
        return 0
    else
        log_error "IP no coincide. Esperado: ${expected_ip}, Actual: ${current_ip}"
        return 1
    fi
}

verify_dns_configuration() {
    local expected_dns="$1"
    
    log_info "Verificando configuración DNS..."
    
    local current_dns=$(get_current_dns)
    
    if [[ "${current_dns}" == "${expected_dns}" ]]; then
        log_success "DNS configurado correctamente: ${current_dns}"
        return 0
    else
        log_warning "DNS podría no estar aplicado inmediatamente: ${current_dns}"
        return 0
    fi
}

# ============================================================================
# DEPENDENCY MANAGEMENT
# ============================================================================
check_required_commands() {
    local missing=()
    local required=("ip" "grep" "awk" "netplan")
    
    for cmd in "${required[@]}"; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing+=("${cmd}")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Comandos requeridos faltantes: ${missing[*]}"
        return 1
    fi
    
    log_success "Todas las dependencias están disponibles"
    return 0
}

# ============================================================================
# REPORTING
# ============================================================================
print_summary() {
    local interface="$1"
    local ip="$2"
    local netmask="$3"
    local gateway="$4"
    local dns="$5"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         CONFIGURACIÓN DE RED - RESUMEN FINAL           ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "Interfaz:     ${interface}"
    echo "IP:           ${ip}/${netmask}"
    echo "Gateway:      ${gateway}"
    echo "DNS:          ${dns}"
    echo "Config:       ${NETPLAN_CONFIG}"
    echo "Resolv:       ${RESOLV_CONFIG}"
    echo "Log:          ${LOG_FILE}"
    echo ""
}

# ============================================================================
# MAIN WORKFLOW
# ============================================================================
main() {
    log_info "╔════════════════════════════════════════════════════════╗"
    log_info "║   Network Static IP Configuration - Docker Optimized   ║"
    log_info "╚════════════════════════════════════════════════════════╝"
    
    check_root
    acquire_lock
    
    # Validar dependencias
    if ! check_required_commands; then
        log_error "Dependencias faltantes en el sistema"
        exit 1
    fi
    
    # Detectar configuración actual
    log_info "Detectando configuración de red DHCP..."
    local interface
    interface=$(get_primary_interface) || exit 1
    
    local current_ip
    current_ip=$(get_current_ip "${interface}") || exit 1
    
    local current_gateway
    current_gateway=$(get_current_gateway "${interface}") || exit 1
    
    local netmask
    netmask=$(get_netmask "${interface}") || exit 1
    
    log_info "Interfaz detectada: ${interface}"
    log_info "IP actual (DHCP): ${current_ip}/${netmask}"
    log_info "Gateway detectado: ${current_gateway}"
    
    # Validaciones
    if ! validate_ip "${current_ip}"; then
        log_error "IP detectada inválida: ${current_ip}"
        exit 1
    fi
    
    if ! is_in_network_range "${current_ip}" "10.10.3"; then
        log_warning "IP no está en el rango esperado (10.10.3.x)"
        log_warning "IP actual: ${current_ip}"
    fi
    
    # Aplicar configuración
    log_info "Generando configuración estática..."
    generate_netplan_config "${interface}" "${current_ip}" "${netmask}" "${ROUTER_GATEWAY}" "${DNS_SERVER}"
    
    log_info "Configurando DNS..."
    configure_resolv_conf "${DNS_SERVER}"
    
    log_info "Aplicando cambios de red..."
    if apply_netplan_config; then
        if verify_network_configuration "${interface}" "${current_ip}"; then
            verify_dns_configuration "${DNS_SERVER}"
            log_success "✓ Configuración completada exitosamente"
            print_summary "${interface}" "${current_ip}" "${netmask}" "${ROUTER_GATEWAY}" "${DNS_SERVER}"
            return 0
        else
            log_error "Verificación fallida"
            return 1
        fi
    else
        log_error "Fallo en la aplicación de configuración"
        return 1
    fi
}

# ============================================================================
# ENTRY POINT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi