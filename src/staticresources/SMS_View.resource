    [id*=popupButtons]{
       padding: 10px;
    }

    .popupbtn{
      padding: 3px;
      margin: 3px;
      width: 100px;
    }
    .popupBlock{
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        background-color: white;
        z-index: 9999;
        left:50%;
        padding:30px;
        position: absolute;
        width:250px;
        margin-left: -250px;
        top: 200px;
        border-radius: 10px;
        border: 1px solid gray;
    }
    .popupBg{
        background-color:lightblue;
        opacity: 0.20;
        filter: alpha(opacity = 20);
        position: absolute;
        width: 100%;
        height:100%;
        top:0;
        left: 0;
        z-index: 9998;
        display: flex;
    }
