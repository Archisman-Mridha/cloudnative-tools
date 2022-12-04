const express= require("express"),
    app= express( )

const cors= require("cors")
app.use(cors( ))

app.get("/",
    (_, response) => response.send("server is running")
)

const PORT= 4000

app.listen(PORT,
    ( ) => console.log("server starting at http://localhost:" + PORT)
)