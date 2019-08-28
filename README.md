# portDetector

This is a bash script that detects newly or accidentally opened ports in your network. Once script runs, it scans all the ports and wait 6 hours, then scans again, considers both results, if there is a difference, then sends an notification email, and then loops forever to do these steps again. 

### Prerequisites
Make sure nmap and python is installed.

### Screenshots
In order demonstrate how it works, I simply opened 888 port right after the initial scan. Then it detected the change and sent the email about it.

![portDetector](https://user-images.githubusercontent.com/51833205/63828112-82d79080-c976-11e9-9a43-3dd58762fb91.png)

![portDetector2](https://user-images.githubusercontent.com/51833205/63828389-57a17100-c977-11e9-893a-d0c1847e1d33.png)
