# Club Member Data Cleaning Project 

## Introduction
A fake dataset of club member information sourced from online.

## Aim 
The purpose of this project is to clean the Club Member data

## Problem Statement
Before any analysis can be done on a dataset, it is professional to ensure that the data is clean so as to get reliable analysis and prevent misleading and inaccurate resuls. The following issues were observed in the data:
- No primary id.
- Presence of special characters in a column that is only suppossed to be alphabets.
- Some ages have an extra digir at the rear.
- Duplicate email addresses.
- Presence of extra whitespaces.
- Outliers in the membership_dates column, reading 1900s instead of 2000s.
- Incomplete phone numbers.

## Dataset used
The dataset used is a csv file and the initail data type are as follows;

- full_name: text
- age: int
- marital_status
- email: text
- phone: text
- full_address: text
- job_title: text
- membership_date: date

