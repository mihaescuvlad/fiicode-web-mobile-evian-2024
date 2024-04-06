import React, {useState, useEffect} from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Line } from 'react-chartjs-2';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

export const options = {
    responsive: true,
    plugins: {
        legend: {
            position: 'top',
        },
        title: {
            display: true,
            text: 'Nutrition Chart',
        },
    },
};

const DietaryChart = (props) => {
    console.log(props.data)
    const data = {
        labels: props.data.map((_, index) => index),
        datasets: [
            {
                label: 'Calories',
                data: props.data.map((data) => data.calories_eaten),
                borderColor: 'rgb(255, 99, 132)',
                backgroundColor: 'rgba(255, 99, 132, 0.5)',
            },
            {
                label: 'Protein',
                data: props.data.map((data) => data.protein_eaten),
                borderColor: 'rgb(54, 162, 235)',
                backgroundColor: 'rgba(54, 162, 235, 0.5)',
            },
            {
                label: 'Carbs',
                data: props.data.map((data) => data.carbs_eaten),
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.5)',
            },
            {
                label: 'Fat',
                data: props.data.map((data) => data.fat_eaten),
                borderColor: 'rgb(153, 102, 255)',
                backgroundColor: 'rgba(153, 102, 255, 0.5)',
            },
        ],
    };

    return <div className="size-full">
        <Line options={options} data={data} />
    </div>
}

export default DietaryChart;