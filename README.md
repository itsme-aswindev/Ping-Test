# PowerShell Server Monitoring and Reporting Script

## 📌 Overview

This PowerShell script allows you to continuously monitor the health and availability of multiple servers. It collects key metrics such as:

- **Ping status** (availability)
- **CPU utilization**
- **Memory utilization**
- **C:\ drive usage**
- **Uptime**

It generates a **detailed HTML report** summarizing all the above information in a clean, readable format. The report is automatically updated as the script runs.

---

## 📂 Features

- 📶 Real-time server availability check using `Test-Connection`
- 📊 Resource metrics collection via WMI (`Get-WmiObject`)
- 📋 Uptime and performance tracking
- 🧾 HTML report generation with table view
- ⏱ Continuous monitoring with update intervals

---

## ✅ Prerequisites

- **PowerShell 5.1 or later**
- **WMI access** enabled and allowed on target servers
- Servers must be **reachable via network**
- A `servers.txt` file containing the list of server hostnames or IP addresses

---

## 🗂 How to Use

1. **Clone this repository or download the script.**

2. **Create a file named `servers.txt`** in the same directory as the script, with each server name or IP address on a new line:
    ```
    server1.domain.com
    192.168.1.10
    server3
    ```

3. **Run the PowerShell script as Administrator:**

    ```powershell
    .\ServerMonitoringReport.ps1
    ```

4. **The script will generate an HTML report** (e.g., `ServerStatusReport.html`) in the same directory, which is updated regularly.

---

## 🧪 Sample Output

A sample HTML output file (`SampleReport.html`) is included in this repo for demonstration purposes.

---

## 📄 Report Format

| Server Name | Status | CPU Usage | Memory Usage | C:\ Drive Usage | Uptime |
|-------------|--------|-----------|--------------|------------------|--------|
| server1     | Online | 23%       | 56%          | 78%              | 3 Days |
| server2     | Offline| -         | -            | -                | -      |

---

## ⚠️ Notes

- Ensure firewall rules and administrative privileges allow WMI queries.
- For accurate data, run the script using an account with proper access to remote machines.

---

## 📌 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 🙌 Acknowledgments

Inspired by real-world infrastructure monitoring needs using native PowerShell and WMI.

