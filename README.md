README file.

# Databases-NTUA

This repository contains the Semester Project for the **Databases** course of **ECE NTUA**.

## Project Overview
This repository is the Semester Project of Databases of ECE NTUA.
We were asked to develop a functional DB that could be used in a music festival
Used MySQLWorkbench for designing the DB
Python for filling the DB with data
DDL, DML, E-R Diagram and Relational Diagram of the DB can be found in the appropriate directories

## Assumptions & Constraints

The database was developed based on the following assumptions:

- 🌼 The festival is **annual** and takes place in **June**, lasting **three days**.  
  Data insertion for each year’s festival begins **one month** after the previous one ends to ensure data consistency and clean-up of `resell_queues`.
  
- 🌼 Each **event lasts 12 hours**, and **multiple events** are held **daily** on **different stages**.

- 🌼 There is an **infinite supply** of **personnel** and **equipment** relative to the needs of the festival, simplifying scheduling constraints.

- 🌼 Each **band** is associated with **only one sub-genre**.

- 🌼 **Ticket activation** is a **manual process** performed by staff **on the day of the event**.  
  No automated system triggers or procedures are used for this process.