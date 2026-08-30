package efs.task.reflection.json;

import java.util.Date;
import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;


@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_EMPTY)
@JsonPropertyOrder({"ProductID", "ProductName", "ProductPrice", "DateOfProduction", "DateOfExpiry"})
public class ProductDTO
{
    private Long id;

    private String name;

    private BigDecimal price;

    private Date expiryDate;

    private Date productionDate;

    @JsonProperty("ProductID")
    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    @JsonProperty("ProductName")
    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    @JsonProperty("ProductPrice")
    public BigDecimal getPrice()
    {
        return price;
    }

    public void setPrice(BigDecimal price)
    {
        this.price = price;
    }

    @JsonProperty("DateOfProduction")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd@HH:mm:ss")
    public Date getProductionDate()
    {
        return productionDate;
    }

    public void setProductionDate(Date productionDate)
    {
        this.productionDate = productionDate;
    }

    @JsonProperty("DateOfExpiry")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    public Date getExpiryDate()
    {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate)
    {
        this.expiryDate = expiryDate;
    }

    @Override
    public String toString()
    {
        return "ProductDTO{" + "id=" + id + ", name='" + name + '\'' + ", price=" + price + ", productionDate=" + productionDate + ", expiryDate=" + expiryDate + '}';
    }
}