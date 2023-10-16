package api

import (
	"github.com/avinal/intervirt/backend/pkg/controller"
	"github.com/avinal/intervirt/backend/pkg/models"
	"github.com/gin-gonic/gin"
	"github.com/gin-contrib/cors"
)

func Router() *gin.Engine {
	r := gin.Default()
	r.Use(cors.Default())
	r.GET("/ping", sayHello)
	r.POST("/vm", createVMHandler)
	r.DELETE("/vm", deleteVMhandler)
	r.POST("/vm/terminal", getVMTerminal)
	return r

}

func sayHello(c *gin.Context) {
	c.JSON(200, gin.H{"message": "pong"})
}

func createVMHandler(c *gin.Context) {
	var req models.CreateVMRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	createdName, err := controller.CreateVMWithKubeVirt(req.VMName, req.ImageName, req.Memory)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	var resp models.CreateVMResponse
	resp.VMName = createdName
	c.JSON(200, resp)
}

func deleteVMhandler(c *gin.Context) {
	var req models.DeleteVMRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	if err := controller.DeleteVirtualMachine(req.VMName); err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	var resp models.DeleteVMResponse
	resp.VMName = req.VMName

	c.JSON(200, resp)
}

func getVMTerminal(c *gin.Context) {
	var req models.GetVMTerminalRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	url, err := controller.GetVMTerminal(req.VMName)

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	var resp models.GetVMTerminalResponse
	resp.Url = url

	c.JSON(200, resp)
}
