package com.unityinflow.sample.shipment

import com.unityinflow.sample.api.ConflictException
import com.unityinflow.sample.api.ErrorCode
import com.unityinflow.sample.api.ResourceNotFoundException
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/**
 * Baseline shipment API: create, read, list.
 *
 * There is deliberately no way to confirm a shipment. That is BE-003.
 */
@RestController
@RequestMapping("/shipments")
class ShipmentController(
    private val repository: InMemoryShipmentRepository,
) {

    @PostMapping
    fun create(@RequestBody request: CreateShipmentRequest): ResponseEntity<Shipment> {
        if (repository.existsById(request.shipmentId)) {
            throw ConflictException(
                ErrorCode.SHIPMENT_ALREADY_EXISTS,
                "A shipment with id '${request.shipmentId}' already exists",
            )
        }

        val saved = repository.save(
            Shipment(
                shipmentId = request.shipmentId,
                orderId = request.orderId,
                carrier = request.carrier,
                status = ShipmentStatus.CREATED,
            ),
        )
        return ResponseEntity.status(HttpStatus.CREATED).body(saved)
    }

    @GetMapping("/{shipmentId}")
    fun getById(@PathVariable shipmentId: String): Shipment =
        repository.findById(shipmentId)
            ?: throw ResourceNotFoundException(
                ErrorCode.SHIPMENT_NOT_FOUND,
                "No shipment with id '$shipmentId'",
            )

    @GetMapping
    fun list(): List<Shipment> = repository.findAll()

    @PostMapping("/{shipmentId}/confirm")
    fun confirm(@PathVariable shipmentId: String): ResponseEntity<Shipment> {
        val shipment = repository.findById(shipmentId)
            ?: throw ResourceNotFoundException(
                ErrorCode.SHIPMENT_NOT_FOUND,
                "No shipment with id '$shipmentId'",
            )

        if (shipment.status == ShipmentStatus.CANCELLED) {
            throw ConflictException(
                ErrorCode.SHIPMENT_INVALID_STATUS,
                "Cannot confirm a shipment in CANCELLED status",
            )
        }

        // If already CONFIRMED, return it unchanged (idempotent)
        if (shipment.status == ShipmentStatus.CONFIRMED) {
            return ResponseEntity.ok(shipment)
        }

        // Move from CREATED to CONFIRMED
        val confirmed = shipment.copy(status = ShipmentStatus.CONFIRMED)
        val saved = repository.save(confirmed)
        return ResponseEntity.ok(saved)
    }
}

// stale-maker 20261005T200803Z rep 3
