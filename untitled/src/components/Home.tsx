import React, {useState} from 'react';

const downArrowMFR = () => {
    return (
        <div><h1>test</h1></div>
    )
}



const ArrowToggle:React.FC = () => {
    // State to keep track of arrow direction
    const [arrowDirection, setArrowDirection] = useState('down');


    // Function to toggle arrow direction
    const toggleArrow = () => {
        setArrowDirection(arrowDirection === 'down' ? 'right' : 'down');
    };

    const arrowStyle = {
        fill: 'white', // Set the fill color to white (or any color that contrasts with your background)
        width: '50px', // Increase the width of the SVG for better visibility
        height: '50px', // Increase the height of the SVG for better visibility
        cursor: 'pointer', // Change cursor to pointer when hovering over the arrow
    };


    return (
        <div onClick={toggleArrow}>
            {arrowDirection === 'down' ? (
                <svg style={arrowStyle} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M7 10l5 5 5-5z"/>
                </svg>

            ) : (
                <svg style={arrowStyle} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M10 7l5 5-5 5v-10z"/>
                </svg>
            )}
            {arrowDirection === 'down' && downArrowMFR()}

        </div>
    );  
};

export default ArrowToggle;
