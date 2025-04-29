# Biodiversity Visualization App

This Shiny application allows users to visualize species observations on a map. The app utilizes data from the **Global Biodiversity Information Facility (GBIF)** and allows users to search for species by vernacular and scientific names, view the species’ observations on the map, and analyze the timeline of their observations. The app is optimized for performance, usability, and scalability.

[Here](https://spex-appsilon-app.azurewebsites.net/). one can find deployed version on Azure. 

## Features

- **Species Search**: Users can search for species by their vernacular name or scientific name. The search is powered by auto-suggestions and returns matching results when the user starts typing.
- **Map Visualization**: Once a species is selected, its observation locations are displayed on an interactive map using `leaflet`. The complete data for the whole world have been used.
- **Timeline Visualization**: Users can view the timeline of selected species' observations.
- **Aggregating dropdown for timeline**: Additional feature to aggregate counts per day/month/year.
- **Default View**: The app displays a relevant default view when no species is selected yet, showing the closest spieces, the user can observe based on geo coordinates.
- **Display of the image and fun facts for chosen spieces**: Once a spieces is selected, an image is presented as well as 3 top fun facts.

## Additional Features (Optional)

- **User Interface**: A visually appealing dashboard styled using CSS/Tailwind to enhance the user experience.
- **Performance Optimization**: The app efficiently handles large datasets, such as global species observations, and ensures fast search and load times.
- **JavaScript Integration**: Custom JavaScript visualizations and handlers are incorporated, such as interactive timelines or species information popups and CountUp.
- **Custom Deployment**: Deployed on a Azure using Azure Container Registry and App Services instead of shinyapps.io for more control and scalability.

## Project Structure

- **Modules**: The app has been decomposed into independent Shiny modules to make the codebase modular, scalable, and maintainable.
- **Testing**: Unit tests are included for critical functions, ensuring robustness and stability.
- **Documentation**: The app includes comments and detailed documentation for developers to understand and extend the functionality. High level directories are

```plaintext
├── app1.R                         # Main application file
├── globals.R                      # Global variables and configurations
├── modules/                       # Directory for Shiny modules
├── utils/                         # Directory for utility functions
├── www/                           # Custom CSS styles and JS Handlers
```

  
## Installation & Setup

To get the app running locally, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/appsilon-hiring/appsilon-shiny-app.git
cd appsilon-shiny-app
```

### 2. Install R and Dependencies

Make sure you have **R** (version 4.0 or above) installed, then run the following command to install the required R packages:

```r
install.packages(c(
  "shiny", "leaflet", "dplyr", "data.table", "highcharter", 
  "lubridate", "DT", "glue", "geosphere", "httr", "jsonlite", 
  "duckdb", "DBI", "shinyjs", "stringr", "AzureStor"
))
```

For package management and testing, you can also use `renv` (if included in the repo) to manage project-specific dependencies:

```bash
# If you have renv installed:
renv::restore()
```

### 3. Run the Application

After installing the dependencies, run the app with the following command:

```r
shiny::runApp("app1.R")
```

The app will be available at [http://0.0.0.1:8180](http://0.0.0.1:8180).

### 4. Deployment (with Docker) (Optional)

To deploy the dockerized app on Azure please follow the steps below:

#### Example Deployment on Azure (with Docker)

1. **Build Docker Image**:

   ```bash
   docker build -t biodiversity-app .
   ```

2. **Push Docker Image to Azure Container Registry**:

   ```bash
   az acr login --name <your_acr_name>
   docker tag biodiversity-app <your_acr_name>.azurecr.io/biodiversity-app:latest
   docker push <your_acr_name>.azurecr.io/biodiversity-app:latest
   ```

3. **Deploy to Azure App Services**:
   Follow the instructions from Azure's documentation to deploy the Docker image to Azure App Services.

#### Ready-to-use application deployed on Azure.

To take a benefit that all steps above have been made already one are welcome to test the app [here](https://spex-appsilon-app.azurewebsites.net/).

## Functionality Overview

### **1. Species Search**
The search bar allows users to search by **vernacular name** or **scientific name**. The app queries a local DuckDB database (pre-loaded with species data from GBIF), ensuring fast and efficient searching. Results are displayed dynamically as the user types.

### **2. Map Visualization**
Once a species is selected, its observed locations in Poland are shown on the map using `leaflet`. The map can be zoomed and panned for detailed exploration.

### **3. Timeline Visualization**
When a species is selected, a timeline of its observations is rendered using `highcharter`. The timeline is interactive, allowing users to zoom in and out to explore trends over time.

## Performance Optimization

To ensure the app is scalable and performs well even with large datasets:

- **Pre-caching data**: Data from GBIF is pre-cached and stored in the app's environment to avoid repeated queries to the external database.
- **Efficient querying**: We use **DuckDB** to query the large GBIF dataset. DuckDB is optimized for reading and querying partitioned Parquet files, making it highly efficient for this task.
- **Data partitioning**: Data is partitioned either `scientificName` first letter or `vernacularName` first letter, reducing the number of records loaded into memory at any given time.

## Testing

### Unit Tests

Unfortunately I did not finish this part, but I think I would manage to cover it within 1-2 days.

## Technology Stack

- **Shiny**: For building the interactive web application.
- **Leaflet**: For interactive map visualization.
- **Highcharter**: For rendering interactive timelines and charts.
- **DuckDB**: For fast querying and in-memory data handling.
- **Azure Blob Storage**: For storing the large dataset, ensuring it can be accessed efficiently by the app.
- **CSS/Tailwind**: For styling the dashboard and improving the visual appearance.
- **Javascript**: For popups, custom handlers like CountUp.

## Potential improvements

1. On the landing page, where user can find the closes spieces, if location allowed, even though observation changes, the picture url is the same - fixed. Definitely to improve when time allows.
2. Using first letter for paritioning causes two issues:
   + some partitions are bigger, not equally distributed, and this should be improved - e.g searching for `number_LADY BIRD` takes longer because partition is big.
   + some partitions have mixed stuff, because of punctation marks & digits as first signs in the name. This should be cleaned.
3. When I read the task for the first time I discovered that maybe filters should be cascade in the sense that firstly we choose `scientificName` and then reactively `vernacularName`. That logic also could be implemented depending on the requirements.
4. I mixed CSS with Tailwind - that is not so clean and clear and should be improved
5. Some reactive values do not work as they supposed to be - especially when generating data - some stuff update automatically, some after clicking - my mistake and should be reviewed carefully.
6. Some observation had more pictures, if I had more time I would have implemented the carousel window instead just picking the first image to give a user to chance to see all pictures as well as the author of the image.
7. In general, map should be optimized, either with `leafletProxy` or initially putting some clusters instead of just marking points separately.
8. I would tweak more the colors and UI part with more uniform colors etc.

---

### README Enhancements for Senior Developer Role

1. **Well-documented Code**: Ensure that each function is well-commented to explain what it does, why it's implemented that way, and any assumptions made.
2. **Performance Justification**: Provide concrete examples and benchmarking to justify the performance optimizations made in your code. Senior developers appreciate details like query performance improvements, memory management, and other optimizations.
3. **Deployment Instructions**: Detailed and clear instructions on deploying to a cloud platform demonstrate your infrastructure knowledge and ability to handle production-level systems.
4. **Testing**: Highlight your unit testing approach, edge cases covered, and how tests were implemented in the repo. Mention any CI/CD tools if you’re using them.
5. **UI/UX**: Mention the visual design decisions, any special visualizations, or JS interactivity that enhances user experience.

By following this structure, your **README** will provide a comprehensive overview that will impress a senior developer, demonstrating your professionalism and technical expertise.
