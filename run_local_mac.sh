#!/usr/bin/env bash
set -e
export DATABASE_URL="jdbc:mysql://localhost:3306/pdts_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Manila"
export DATABASE_USERNAME="${DATABASE_USERNAME:-pdts_user}"
export DATABASE_PASSWORD="${DATABASE_PASSWORD:-pdts_local_2026}"
export PORT="${PORT:-8080}"
mvn spring-boot:run
