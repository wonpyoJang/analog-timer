@echo off
chcp 65001 >nul
title Analog Timer Diagnostics
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0analog-timer-diag.ps1"
