library(tidyverse)
library(pdftools)
library(png)

format.lulu.pdf <- function(i.pdf, i.out = getwd(), i.cpdf = "H:/Portables/cpdf",
                            i.magick = "C:/Program Files/ImageMagick-7.0.9-Q16", 
                            i.booksize="US Letter", i.width = 8.5, i.height = 11, 
                            i.white = 0.10, i.shift.odd = 0.05, i.shift.even = -0.05,
                            i.pages.front=NA,
                            i.pages.back=NA,
                            i.pages.contents=NA,
                            i.pages.add=NA,
                            i.delete.temp=T,
                            i.additional.shifts=data.frame(),
                            i.ppp = 300,
                            i.spine = NA,
                            i.spine.color="#000000",
                            i.rotate.right=NA,
                            i.rotate.left=NA,
                            i.convert="-trim +repage",
                            i.embedded.fonts=F) {

  if(!dir.exists(i.out)) dir.create(i.out)

  books <- data.frame(booksize=c("US Trade","US Letter","Digest","Executive","A5","A4","Royal","Crown Quarto","Square","Small Square","Pocket Book","US Letter Landscape","A4 Landscape","Small Landscape","Calendar","Comic Book"),
                      width=c(6,8.5,5.5,7,5.83,8.27,6.14,7.44,8.5,7.5,4.25,11,11.69,9,11,6.63),
                      height=c(9,11,8.5,10,8.27,11.69,9.21,9.68,8.5,7.5,6.875,8.5,8.27,7,8.5,10.25), stringsAsFactors=F) %>%
    mutate(booksizel=tolower(booksize), aspect=height/width)
  
  cat("Informacion:\n")
  info <- pdf_info(i.pdf)
  pages <- pdf_pagesize(i.pdf)
  cat("\tProcesando ", i.pdf,"\n")
  cat("\tTamanio original: ", pages$width[2] / 72, " x ", pages$heigh[2] / 72,"\n" , sep="")

  if (is.numeric(i.width)) i.width <- i.width[1] else i.width = 8.5
  if (is.numeric(i.height)) i.height <- i.height[1] else i.height = 11
  if (is.character(i.booksize)){
    temp1 <- books[tolower(i.booksize)==books$booksizel,]
    if (NROW(temp1)>0){
      cat("\tFormato final: ",i.booksize,"\n", sep="")
      i.width <- temp1$width[1]
      i.height <-temp1$height[1]
    }
  }
  if (!(is.numeric(i.width) & length(i.width)==1 & is.numeric(i.height) & length(i.height)==1)) stop("Cannot determine width and height\n")
  cat("\tTamanio final: ",i.width," x ",i.height,"\n", sep="")
  
  if (is.na(i.pages.front)) i.pages.front <- "1"
  if (is.na(i.pages.back)) i.pages.back <- as.character(info$pages)
  if (is.na(i.pages.contents)) i.pages.contents <- paste0("2-",info$pages - 1)

  cpdf.file <- file.path(i.cpdf, "cpdf.exe")
  conv.file <- file.path(i.magick, "convert.exe")

  # png::writePNG(pdf_render_page(i.pdf, page = 1, dpi = 300), file.path(i.out, "portada.png"))
  # png::writePNG(pdf_render_page(i.pdf, page = pdf_length(i.pdf), dpi = 300), file.path(i.out, "contraportada.png"))
  # pdf_subset(i.pdf, pages = 1, output = file.path(i.out, "portada.pdf"))
  
  # Extraer portada a pdf
  cat("Extrayendo paginas:\n")
  cat("\tPortada: ", i.pages.front, "\n", sep="")
  system.out.null <- system(paste0("\"",cpdf.file, "\" \"", i.pdf, "\" ",i.pages.front," -o \"", file.path(i.out, "portada.pdf"), "\""), intern = T)
  # Convertir portada a png
  system.out.null <- system(paste0("\"",conv.file,"\" -density 300 \"",file.path(i.out, "portada.pdf"),"\" ",i.convert," \"",paste0(tools::file_path_sans_ext(file.path(i.out, "portada.pdf")),".png"),"\""), intern = T)
  # Extraer contraportada a pdf
  cat("\tContraportada: ", i.pages.back,"\n", sep="")
  system.out.null <- system(paste0("\"",cpdf.file, "\" \"", i.pdf, "\" ",i.pages.back," -o \"", file.path(i.out, "contraportada.pdf"), "\""), intern = T)
  # Convertir contraportada a png
  system.out.null <- system(paste0("\"",conv.file,"\" -density 300 \"",file.path(i.out, "contraportada.pdf"),"\" ",i.convert," \"",paste0(tools::file_path_sans_ext(file.path(i.out, "contraportada.pdf")),".png"),"\""), intern = T)
  # pdf_subset(i.pdf, pages = 2:(pdf_length(i.pdf)-1), output = file.path(i.out, "texto1.pdf"))
  # Extraer contenidos
  cat("\tContenidos: ", i.pages.contents,"\n", sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" \"", i.pdf, "\" ", i.pages.contents, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T)
  cat("Manipulando contenidos:\n")
  # Rotando paginas
  if (!is.na(i.rotate.right)){
    cat("\tRotando paginas a la derecha: ", i.rotate.right,"\n", sep="")
    # system.out.null <- system(paste0("\"", cpdf.file, "\" -rotate-contents 90 \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.right, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
    system.out.null <- system(paste0("\"", cpdf.file, "\" -rotate 90 \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.right, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
    system.out.null <- system(paste0("\"", cpdf.file, "\" -upright \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.right, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
  }  
  if (!is.na(i.rotate.left)){
    cat("\tRotando paginas a la derecha: ", i.rotate.left,"\n", sep="")
    # system.out.null <- system(paste0("\"", cpdf.file, "\" -rotate-contents 270 \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.left, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
    system.out.null <- system(paste0("\"", cpdf.file, "\" -rotate 270 \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.left, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
    system.out.null <- system(paste0("\"", cpdf.file, "\" -upright \"", file.path(i.out, "texto1.pdf"), "\" ", i.rotate.left, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
  }  
  # Aniadir paginas en blanco
  if (!is.na(i.pages.add)){
    cat("\tA?adiendo p?ginas en blanco: ", i.pages.add,"\n", sep="")
    system.out.null <- system(paste0("\"", cpdf.file, "\" -pad-after \"", file.path(i.out, "texto1.pdf"), "\" ", i.pages.add, " -o \"", file.path(i.out, "texto1.pdf"), "\""), intern = T) 
  }
  # Etiquetar paginas automaticamente
  numbering <- paste0("1-", pdf_info(file.path(i.out, "texto1.pdf"))$pages, sep="")
  cat("\tEtiquetando: ", numbering,"\n", sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -add-page-labels \"", file.path(i.out, "texto1.pdf"), "\" ",numbering," -label-style DecimalArabic -o \"", file.path(i.out, "texto2.pdf"), "\""), intern = T)
  # system(paste0("\"",cpdf.file, "\" -missing-fonts \"",file.path(i.out, "texto2.pdf"), "\""), intern = T)
  if (!i.embedded.fonts){
    temp1 <- pdf_fonts(i.pdf) %>%
      filter(!embedded) 
    if (NROW(temp1)>0){
      cat("\t?AVISO! Fuentes no incrustadas:\n")
      print(temp1)
    }
    rm("temp1")    
  }
  # Escalado de seguridad
  cat("\tEscalado de seguridad: ", i.width + 0.25 - i.white, "x",i.height + 0.25 - i.white,"\n", sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -scale-to-fit \"", i.width + 0.25 - i.white, "in ", i.height + 0.25 - i.white, "in\" \"", file.path(i.out, "texto2.pdf"), "\" -o \"", file.path(i.out, "texto3.pdf"), "\""), intern = T)
  # Moviendo a derecha e izquierda para el lomo
  cat("\tMoviendo paginas impares: ", ifelse(i.shift.odd>0, paste0(i.shift.odd, " a la derecha.\n",sep=""), paste0(-i.shift.odd, " a la izquierda.\n",sep="")), sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -shift \"", i.shift.odd, "in 0in\" \"", file.path(i.out, "texto3.pdf"), "\" odd -o \"", file.path(i.out, "texto4.pdf"), "\""), intern = T)
  cat("\tMoviendo paginas pares: ", ifelse(i.shift.even>0, paste0(i.shift.even, " a la derecha.\n",sep=""), paste0(-i.shift.even, " a la izquierda.\n",sep="")), sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -shift \"", i.shift.even, "in 0in\" \"", file.path(i.out, "texto4.pdf"), "\" even -o \"", file.path(i.out, "texto5.pdf"), "\""), intern = T)
  # Movimientos adicionales de hojas
  if (NROW(i.additional.shifts)>0){
    temp1 <- i.additional.shifts %>%
      select(shift) %>%
      distinct()
    for (i in 1:NROW(temp1)){
      temp2 <- i.additional.shifts %>%
        filter(shift==temp1$shift[i]) %>%
        pull(page) %>%
        paste(collapse=",")
      cat("\tMoviendo paginas adicionales: ",temp2,": ", ifelse(temp1$shift[i]>0, paste0(temp1$shift[i], " a la derecha.\n",sep=""), paste0(-temp1$shift[i], " a la izquierda.\n",sep="")), sep="")
      system.out.null <- system(paste0("\"", cpdf.file, "\" -shift \"", temp1$shift[i], "in 0in\" \"", file.path(i.out, "texto5.pdf"), "\" ",temp2," -o \"", file.path(i.out, "texto5.pdf"), "\""), intern = T)
      rm("temp2")
    }
    rm("temp1")
  }
  # Escalado final para generar espacio en blanco
  cat("\tEscalado final generando espacio blanco: ", i.width + 0.25, "x",i.height + 0.25,"\n", sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -scale-to-fit \"", i.width + 0.25 - i.white, "in ", i.height + 0.25, "in\" \"", file.path(i.out, "texto5.pdf"), "\" -o \"", file.path(i.out, "texto6.pdf"), "\""), intern = T)
  system.out.null <- system(paste0("\"", cpdf.file, "\" -scale-to-fit \"", i.width + 0.25, "in ", i.height + 0.25, "in\" \"", file.path(i.out, "texto6.pdf"), "\" -o \"", file.path(i.out, "texto7.pdf"), "\""), intern = T)
  # Comprimir
  cat("Procesado final:\n", sep="")
  cat("\tComprimiendo el fichero final.\n", sep="")
  system.out.null <- system(paste0("\"", cpdf.file, "\" -squeeze \"", file.path(i.out, "texto7.pdf"), "\" -o \"", file.path(i.out, "textofinal.pdf"), "\""), intern = T)
  pages <- pdf_pagesize(file.path(i.out, "textofinal.pdf"))
  cat("\tFichero final ", file.path(i.out, "textofinal.pdf"),"\n", sep="")
  cat("\tAncho: ", pages$width[2] / 72, ", Alto: ", pages$heigh[2] / 72,"\n" , sep="")
  
  if (is.numeric(i.spine)){
    t.bleed = round(0.125*i.ppp)
    t.width = round(i.width*i.ppp)
    t.height = round(i.height*i.ppp)
    t.spine = i.spine*i.ppp
    
    cat("\tGenerando portada.\n", sep="")
    systxt <- paste0("\"",conv.file,"\" -size ", t.width*2+t.bleed*2+t.spine,"x",t.height+2*t.bleed," xc:white ",
                     "( xc:\"",i.spine.color,"\" -resize ",(t.width*2+t.spine),"x",t.height,"! ) -geometry +",t.bleed,"+",t.bleed," -composite ",
                     "( \"",file.path(i.out, "contraportada.png"),"\" -resize ",t.width,"x",t.height,"! ) -geometry +",t.bleed,"+",t.bleed," -composite ",
                     "( \"",file.path(i.out, "portada.png"),"\" -resize ",t.width,"x",t.height,"! ) -geometry +",(t.bleed+t.width+t.spine),"+",t.bleed," -composite ",
                     "\"",file.path(i.out, "portadacompleta.png"),"\"")
    system.out.null <- system(systxt, intern = T)
    systxt <- paste0("\"",conv.file,"\" -size ", t.width*2+t.bleed*2+t.spine,"x",t.height+2*t.bleed," xc:white ",
                     "( xc:\"",i.spine.color,"\" -resize ",(t.width*2+t.spine),"x",t.height,"! ) -geometry +",t.bleed,"+",t.bleed," -composite ",
                     "( \"",file.path(i.out, "contraportada.png"),"\" -resize ",t.width,"x",t.height,"! ) -geometry +",t.bleed,"+",t.bleed," -composite ",
                     "( \"",file.path(i.out, "portada.png"),"\" -resize ",t.width,"x",t.height,"! ) -geometry +",(t.bleed+t.width+t.spine),"+",t.bleed," -composite ",
                     "-density 300 -units pixelsperinch \"",file.path(i.out, "portadacompleta.pdf"),"\"")
    system.out.null <- system(systxt, intern = T)
    # convert -size 5320x3375 xc:white 
    # ( 1.png -resize 2550x3300 ) -geometry +37+37 -composite 
    # ( 3.png -resize 2550x3300 ) -geometry +2732+37 -composite 
    # compose_resize.png    
  }

  if (i.delete.temp){
    cat("\tBorrando ficheros temporales.\n", sep="")
    file.remove(file.path(i.out, "texto1.pdf"))
    file.remove(file.path(i.out, "texto2.pdf"))
    file.remove(file.path(i.out, "texto3.pdf"))
    file.remove(file.path(i.out, "texto4.pdf"))
    file.remove(file.path(i.out, "texto5.pdf"))
    file.remove(file.path(i.out, "texto6.pdf"))
    file.remove(file.path(i.out, "texto7.pdf"))
  }
  cat("---------------------------------------\n")
  return(pages)
}
