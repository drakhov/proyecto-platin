#!/bin/bash

./deploy.sh com.backend.ingest.PlatinApplication Platin build.properties backend

./deploy.sh com.backend.WorkerConsoleCalculateGeocerca.WorkerCalculateGeocerca WorkerCalculateGeocerca ingestaWorkers.properties workers

./deploy.sh com.backend.WorkersConsoleTrama.WorkerSaveDataBaseTrama WorkerSaveDataBaseTrama ingestaWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleStoppedCistern.WorkerStoppedCistern WorkerStoppedCistern ingestaWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleTramaWebSocket.WorkerTramaWebSocket WorkerTramaWebSocket ingestaWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleTransmissionLoss.WorkerTransmissionLoss WorkerReportTransmissionLoss ingestaWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleReport.WorkerReport WorkerReport reportWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleTimeLag.WorkerTimeLag WorkerReportTimeLag reportWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleReportTRavels.WorkerReportTravels WorkerReportTravel reportWorkers.properties workers

./deploy.sh com.backend.WorkerConsoleReportSpedd.WorkerReportSpeed ReportSpeed reportWorkers.properties workers

sudo systemctl restart platin-backend-Platin.service
sudo systemctl restart platin-workers-*